import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:riddim_app/Components/historyTrip.dart';
import 'package:riddim_app/Model/mapTypeModel.dart';
import 'package:riddim_app/Model/placeItem.dart';
import 'package:riddim_app/Networking/KonnectApi.dart';
import 'package:riddim_app/Screen/Directions/trip.dart';
import 'package:riddim_app/Screen/Menu/Menu.dart';
import 'package:riddim_app/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app/Screen/SearchAddress/searchAddress2.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';

import 'radioSelectMapType.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userRepository = KonnectRepository();
  final String screenName = "HOME";
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  CircleId selectedCircle;
  int _markerIdCounter = 0;
  GoogleMapController _mapController;
  BitmapDescriptor markerIcon;
  BitmapDescriptor _taxiIcon;
  String currentLocationName;
  String newLocationName;
  Position currentPosition;
  String _placemark = '';
  GoogleMapController mapController;
  CameraPosition _position;
  PlaceItemRes fromAddress;
  PlaceItemRes toAddress;
  bool checkPlatform = Platform.isIOS;
  double distance = 0;
  bool nightMode = false;
  VoidCallback showPersBottomSheetCallBack;
  List<MapTypeModel> sampleData = new List<MapTypeModel>();
  PersistentBottomSheetController _controller;

  bool permission = false;
  String error;
  Position currentLocation;
  Position _lastKnownPosition;
  User _currentUser;
  Timer _everyTenSecond;

  List<dynamic> _upcoming = List<dynamic>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentUser();
    _initLastKnownLocation();
    _initCurrentLocation();
    _updates();
    showPersBottomSheetCallBack = _showBottomSheet;
    sampleData.add(MapTypeModel(1,true, 'assets/style/maptype_nomal.png', 'Nomal', 'assets/style/nomal_mode.json'));
    sampleData.add(MapTypeModel(2,false, 'assets/style/maptype_silver.png', 'Silver', 'assets/style/sliver_mode.json'));
    sampleData.add(MapTypeModel(3,false, 'assets/style/maptype_dark.png', 'Dark', 'assets/style/dark_mode.json'));
    sampleData.add(MapTypeModel(4,false, 'assets/style/maptype_night.png', 'Night', 'assets/style/night_mode.json'));
    sampleData.add(MapTypeModel(5,false, 'assets/style/maptype_netro.png', 'Netro', 'assets/style/netro_mode.json'));
    sampleData.add(MapTypeModel(6,false, 'assets/style/maptype_aubergine.png', 'Aubergine', 'assets/style/aubergine_mode.json'));
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _initLastKnownLocation();
    _initCurrentLocation();
    if(currentLocation != null ){
      moveCameraToMyLocation();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_everyTenSecond != null) _everyTenSecond.cancel();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    Fluttertoast.showToast(
        msg: "Welcome " + user.fullname,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
    setState(() {
      _currentUser = user;
      _getUpcomingTickets();
    });

  }

  void _getUpcomingTickets() async {
    if (_currentUser != null) {
      final results = await userRepository.getUpcomingTickets(
          token: _currentUser.userid,
          date:  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
      );
      print("Upcoming " + results.length.toString());
      setState(() {
        _upcoming = results;
      });
    }
  }

  ///Get last known location
  Future<void> _initLastKnownLocation() async {
    Position position;
    try {
      final Geolocator geolocator = Geolocator()
        ..forceAndroidLocationManager = true;
      position = await geolocator?.getLastKnownPosition(desiredAccuracy: LocationAccuracy.best);
    } on PlatformException {
      position = null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _lastKnownPosition = position;
    });
  }

  /// Get current location
  _initCurrentLocation() async {
    try {
      Geolocator()
        ..forceAndroidLocationManager = true
        ..getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        )?.then((position) {
          if (mounted) {
            currentLocation = position;
            if(currentLocation != null ){
              //_updateMyLocation();
              print(currentLocation.toString());
              moveCameraToMyLocation();
            }
          }
        })?.catchError((e) {
        });
    } on PlatformException {
    }

    if(currentLocation != null){
      List<Placemark> placemarks = await Geolocator()?.placemarkFromCoordinates(currentLocation?.latitude, currentLocation?.longitude);
      if (placemarks != null && placemarks.isNotEmpty) {
        final Placemark pos = placemarks[0];
        setState(() {
          _placemark = pos.name + ', ' + pos.thoroughfare;
          print(_placemark);
          currentLocationName = _placemark;
        });
      }
    }
  }

  void _updates() async {
    _everyTenSecond = Timer.periodic(Duration(seconds: 10), (Timer t) {
      //print("RUNNING TIMER");
      _initCurrentLocation();
      _updateMyLocation();
      _getNearbyUsers();
    });
  }

  void _updateMyLocation() async {
    if (_currentUser != null && currentLocation != null) {
      await userRepository.saveMyLocation(
          token: _currentUser.userid,
          lat: currentLocation?.latitude,
          long: currentLocation?.longitude);
    }
  }

  void _getNearbyUsers() async {
    if (_currentUser != null && currentLocation != null) {
      final results = await userRepository.getNearbyUsers(
          token: _currentUser.userid);

      for (int i = 0; i < results.length; i++) {
        _removeMarker(results[i]['id']);
        _addMarker(results[i]['id'], double.parse(results[i]['lat']), double.parse(results[i]['lng']));
      }
    }
  }


  void _addMarker(String markerIdVal, double lat, double lng) async {
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      icon: _taxiIcon,
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );
    setState(() {
      _markers[markerId] = marker;
    });
  }

  void _removeMarker(String idMarker) {
    final MarkerId markerId = MarkerId(idMarker);
    setState(() {
      _markers.remove(markerId);
    });
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_taxiIcon == null) {
      final ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, checkPlatform ? 'assets/image/icon_car_32.png' : "assets/image/icon_car_120.png")
          .then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _taxiIcon = bitmap;
    });
  }

  void moveCameraToMyLocation(){
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation?.latitude,currentLocation?.longitude),
          zoom: 17.0,
        ),
      ),
    );
  }

  /// Get current location name
  void getLocationName(double lat, double lng) async {
    if(lat != null && lng != null) {
      List<Placemark> placemarks = await Geolocator()?.placemarkFromCoordinates(lat, lng);
      if (placemarks != null && placemarks.isNotEmpty) {
        final Placemark pos = placemarks[0];
        setState(() {
          _placemark = pos.name + ', ' + pos.thoroughfare;
          newLocationName = _placemark;
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    this._mapController = controller;
    MarkerId markerId = MarkerId(_markerIdVal());
    LatLng position = LatLng(currentLocation != null ? currentLocation?.latitude : 10.536421, currentLocation != null ? currentLocation?.longitude : -61.311951);
    Marker marker = Marker(
      markerId: markerId,
      position: position,
      draggable: false,
    );
    setState(() {
      _markers[markerId] = marker;
    });
    Future.delayed(Duration(milliseconds: 200), () async {
      this._mapController = controller;
      controller?.animateCamera(
        CameraUpdate?.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 15.0,
          ),
        ),
      );
    });
  }

  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;
    return val;
  }

  submitLocation(){
    print(_position);
    print(newLocationName);
  }

  Future<String> _getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void _setMapStyle(String mapStyle) {
    setState(() {
      nightMode = true;
      _mapController.setMapStyle(mapStyle);
    });
  }

  void changeMapType(int id, String fileName){
    print(fileName);
    if (fileName == null) {
      setState(() {
        nightMode = false;
        _mapController.setMapStyle(null);
      });
    } else {
      _getFileData(fileName)?.then(_setMapStyle);
    }
  }

  void _showBottomSheet() async {
    setState(() {
      showPersBottomSheetCallBack = null;
    });
    _controller = await _scaffoldKey.currentState
        .showBottomSheet((context) {
      return new Container(
        height: 300.0,
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text("Map type",style: heading18Black,),
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.close,color: blackColor,),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
              Expanded(
                child:
                new GridView.builder(
                  itemCount: sampleData.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      highlightColor: Colors.red,
                      splashColor: Colors.blueAccent,
                      onTap: () {
                        _closeModalBottomSheet();
                        sampleData.forEach((element) => element.isSelected = false);
                        sampleData[index].isSelected = true;
                        changeMapType(sampleData[index].id, sampleData[index].fileName);

                      },
                      child: new MapTypeItem(sampleData[index]),
                    );
                  },
                ),
              )

            ],
          ),
        )
      );
    });
  }

  void _closeModalBottomSheet() {
    if (_controller != null) {
      _controller.close();
      _controller = null;
    }
  }

  _goToTicket(String ticket) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ticket", ticket);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TripScreen())
    );

  }

  @override
  Widget build(BuildContext context) {

    _createMarkerImageFromAsset(context);

    return Scaffold(
        key: _scaffoldKey,
        drawer: _currentUser == null? new MenuScreensDefault(activeScreenName: screenName) : new MenuScreens(activeScreenName: screenName, user: _currentUser),
        body:
        SingleChildScrollView(
          child: Container(
            color: whiteColor,
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 110,
                      child: GoogleMap(
                        markers: Set<Marker>.of(_markers.values),
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              currentLocation != null ? currentLocation?.latitude : _lastKnownPosition?.latitude ?? 10.536421,
                              currentLocation != null ? currentLocation?.longitude : _lastKnownPosition?.longitude ?? -61.311951),
                          zoom: 12.0,
                        ),
                        onCameraMove: (CameraPosition position) {
                          if(_markers.length > 0) {
                            MarkerId markerId = MarkerId(_markerIdVal());
                            Marker marker = _markers[markerId];
                            Marker updatedMarker = marker?.copyWith(
                              positionParam: position?.target,
                            );
                            setState(() {
                              _markers[markerId] = updatedMarker;
                              _position = position;
                            });
                          }
                        },
                        onCameraIdle: () => getLocationName(
                            _position?.target?.latitude != null ? _position?.target?.latitude : currentLocation?.latitude,
                            _position?.target?.longitude != null ? _position?.target?.longitude : currentLocation?.longitude
                        ),
                      ),
                    ),
                    Container(
                      //color: greyColor,
                        height: 110.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                                onTap: (){
                                  _everyTenSecond.cancel();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => SearchAddress2(
                                        newLocationName != null ? newLocationName : "",
                                        _position,
                                      ),
                                      fullscreenDialog: true
                                  ));
                                },
                                child: HistoryTrip(
                                  fromAddress: newLocationName != null ? newLocationName : "",
                                  toAddress: "To address",
                                )
                            )
                          ],
                        )

                    ),
                  ],
                ),
                Positioned(
                  bottom: 120,
                  right: 16,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100.0),),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.my_location,size: 20.0,color: blackColor,),
                      onPressed: (){
                        _initCurrentLocation();
                      },
                    ),
                  )
                ),
                _upcoming.length > 0 ? Positioned(
                  top: 60,
                  right: 10,
                  child: Container(
                    height: 40.0,
                    width: 150.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100.0),),
                    ),
                    child: FlatButton.icon(
                        onPressed: () {
                      _goToTicket(_upcoming[0]["id"]);
                    },
                        icon: Icon(Icons.departure_board,size: 20.0,color: blackColor,),
                        label: Text(_upcoming[0]["time"]),
                    ),
                  )
                ) : Positioned(
                  top: 60,
                  right: 10,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100.0),),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.departure_board,size: 20.0,color: blackColor,),
                      onPressed: (){
                        //_showBottomSheet();
                        Fluttertoast.showToast(
                            msg: "There are no open trips...",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.redAccent,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      },
                    ),
                  )
                ),
                Positioned(
                    top: 60,
                    left: 10,
                    child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(100.0),),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.menu,size: 20.0,color: blackColor,),
                        onPressed: (){
                          _scaffoldKey.currentState.openDrawer();
                        },
                      ),
                    )
                ),
              ],
            ),
          )
        ),
    );
  }
}
