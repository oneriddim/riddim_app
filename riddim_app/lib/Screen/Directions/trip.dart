import 'dart:async';
import 'dart:core';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riddim_app/Components/autoRotationMarker.dart' as rm;
import 'package:riddim_app/Components/customDialogInfo.dart';
import 'package:riddim_app/Components/customDialogInput.dart';
import 'package:riddim_app/Components/loading.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/Message/MessageScreen.dart';
import 'package:riddim_app/data/Model/direction_model.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riddim_app/theme/style.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../Networking/Apis.dart';
import '../../config.dart';
import '../../data/Model/direction_model.dart';
import '../../data/Model/get_routes_request_model.dart';
import '../../google_map_helper.dart';
import 'selectService.dart';

const double _kPickerSheetHeight = 216.0;

class TripScreen extends StatefulWidget {
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final userRepository = KonnectRepository();
  var scaffoldKey = new GlobalKey<ScaffoldState>();
  List<LatLng> points = <LatLng>[];
  GoogleMapController _mapController;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  BitmapDescriptor markerIcon;
  BitmapDescriptor _taxiIcon;

  Map<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  PolylineId selectedPolyline;

  bool checkPlatform = Platform.isIOS;
  String distance, duration;
  int distanceAct, durationAct;
  double cost;
  bool isLoading = true;
  bool isResult = false;
  bool hasDriver = false;
  LatLng positionDriver;
  bool isConfirmed = false;
  bool isComplete = false;
  var apis = Apis();
  List<Routes> routesData;
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();

  User _currentUser;
  Map _ticketInfo;
  Timer _waitForDriver;
  String _ticketId;
  Map driverInfo;
  Position currentLocation;


  String promo;
  String notes;
  DateTime scheduled = DateTime.now();

  void _onMapCreated(GoogleMapController controller) {
    this._mapController = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    promo = "";
    notes = "";
    _getTicketInfo();
//    _createPoints();
  }

  @override
  void dispose() {
    super.dispose();
    _waitForDriver != null ?? _waitForDriver.cancel();
  }

  Future<void> _getTicketInfo() async {
    Fluttertoast.showToast(
        msg: "Getting Details",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ticketId = prefs.get("ticket");
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    final info = await userRepository.ticket(ticket: _ticketId, token: user.userid);

    setState(() {
      _currentUser = user;
      if (info.length > 0) {
        isLoading = false;
        _ticketInfo = info["data"];

        if (_ticketInfo["driverid"] != "-1") {
          driverInfo = new Map<String, dynamic>();
          driverInfo["id"] = _ticketInfo["driverid"];
          driverInfo["name"] = _ticketInfo["name"];
          driverInfo["contact"] = _ticketInfo["contact"];
          driverInfo["vehicle"] = _ticketInfo["vehicle"];
          driverInfo["registration"] = _ticketInfo["registration"];
          driverInfo["rating"] = _ticketInfo["driverrating"];

          hasDriver = true;
          isConfirmed = _ticketInfo["appr"] == "1";
          if(isConfirmed) {
            _trackDriver();
          }
        } else {
          Fluttertoast.showToast(
              msg: "Waiting for Driver...",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Colors.orangeAccent,
              textColor: Colors.white,
              fontSize: 16.0
          );
          _awaitingDriver();
        }

        addMakers();
        getRouter();
      }
    });
  }

  addMakers(){
    checkPlatform ? print('ios'): print("adnroid");
    final MarkerId markerIdFrom = MarkerId("from_address");
    final MarkerId markerIdTo = MarkerId("to_address");


    //var _dataFrom =  widget.dataFrom;
    //var _dataTo =  widget.dataTo;

    final Marker marker = Marker(
      markerId: markerIdFrom,
      position: LatLng(double.parse(_ticketInfo['plat']), double.parse(_ticketInfo['plng'])),
      infoWindow: InfoWindow(title: "Pickup", snippet: _ticketInfo['pickup']),
      icon:  checkPlatform ? BitmapDescriptor.fromAsset("assets/image/gps_point_24.png") : BitmapDescriptor.fromAsset("assets/image/gps_point.png"),
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );

    final Marker markerTo = Marker(
      markerId: markerIdTo,
      position: LatLng(double.parse(_ticketInfo['dlat']), double.parse(_ticketInfo['dlng'])),
      infoWindow: InfoWindow(title: "Drop Off", snippet: _ticketInfo['dropoff']),
      icon: checkPlatform ? BitmapDescriptor.fromAsset("assets/image/ic_marker_32.png") : BitmapDescriptor.fromAsset("assets/image/ic_marker_128.png"),
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );

    setState(() {
      markers[markerIdFrom] = marker;
      markers[markerIdTo] = markerTo;
    });
  }

  ///Calculate and return the best router
  void getRouter() async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    polyLines.clear();
    var router;
    LatLng _fromLocation = LatLng(double.parse(_ticketInfo['plat']), double.parse(_ticketInfo['plng']));
    LatLng _toLocation = LatLng(double.parse(_ticketInfo['dlat']), double.parse(_ticketInfo['dlng']));

    await apis.getRoutes(
      getRoutesRequest: GetRoutesRequestModel(
          fromLocation: _fromLocation,
          toLocation: _toLocation,
          mode: "driving"
      ),
    ).then((data) {
      if (data != null) {
        router = data.result.routes[0].overviewPolyline.points;
        routesData = data.result.routes;
      }
    }).catchError((error) {
      print("GetRoutesRequest > $error");
    });

    distance = routesData[0].legs[0].distance.text;
    distanceAct = routesData[0].legs[0].distance.value;
    duration = routesData[0].legs[0].duration.text;
    durationAct = routesData[0].legs[0].duration.value;

    if (_currentUser != null) {
      cost = double.parse(_currentUser.base??0) + (double.parse(_currentUser.farekm??0) * (distanceAct/1000)) + (double.parse(_currentUser.faremin??0) * (durationAct/60));
    }

    polyLines[polylineId] = GMapViewHelper.createPolyline(
      polylineIdVal: polylineIdVal,
      router: router,
      formLocation: _fromLocation,
      toLocation: _toLocation,
    );
    setState(() {});
    _gMapViewHelper.cameraMove(fromLocation: _fromLocation,toLocation: _toLocation,mapController: _mapController);
  }

  _awaitingDriver() async {
    _waitForDriver = Timer.periodic(Duration(seconds: 10), (Timer t) async {
    final accepted = await userRepository.isTicketAccepted(ticket: _ticketId, token: _currentUser.userid);
    if (accepted["success"]) {
      setState(() {
        driverInfo = accepted["data"];
        _waitForDriver.cancel();
        isLoading = false;
        hasDriver = true;
      });
    } else {
      _updateMyLocation();
    }
  });
  }

  _confirm() async {
    final confirmed = await userRepository.confirmTicket(
      ticket: _ticketId,
      token: _currentUser.userid,
    );
    if (confirmed) {
      setState(() {
        isConfirmed = true;
      });
      _trackDriver();
    }
  }

  _trackDriver() async {
    const timeRequest = const Duration(seconds: 10);
    _waitForDriver = Timer.periodic(timeRequest, (Timer t) async {
      final driverTracker = await userRepository.trackerDriver(
        ticket: _ticketId,
        token: _currentUser.userid,
      );
      Map location = driverTracker["location"];
      if (location.length > 0) {
        positionDriver = new LatLng(double.parse(location["lat"]), double.parse(location["lng"]));
        addMakersDriver(positionDriver);
        _mapController?.animateCamera(
          CameraUpdate?.newCameraPosition(
            CameraPosition(
              target: positionDriver,
              zoom: 15.0,
            ),
          ),
        );
      }
      if (driverTracker["completed"]) {
        setState(() {
          t.cancel();
          isComplete = true;
          showDialog(context: context, builder: (BuildContext context) { return dialogInfo(); },);
        });
      } else {
        _updateMyLocation();
      }
    });
  }

  void _updateMyLocation() async {
    await _initCurrentLocation();
    if (_currentUser != null && currentLocation != null) {
      await userRepository.saveMyLocation(
          token: _currentUser.userid,
          lat: currentLocation?.latitude,
          long: currentLocation?.longitude);
    }
  }

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
            }
          }
        })?.catchError((e) {
        });
    } on PlatformException {
    }
  }

  _cancel() async {
    Fluttertoast.showToast(
        msg: "Cancelling Trip",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
    // TO DO
    await _initCurrentLocation();

    final results = await userRepository.dropoffTicket(
        ticket: _ticketId,
        token: _currentUser.userid,
        lat: currentLocation.latitude.toString(),
        lng: currentLocation.longitude.toString()
    );

    if (results) {
      setState(() {
        _waitForDriver != null ?? _waitForDriver.cancel();
        isComplete = true;
        showDialog(context: context, builder: (BuildContext context) { return dialogInfo(); },);
      });
    } else {
      Fluttertoast.showToast(
          msg: "Could not cancel trip!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
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

  addMakersDriver(LatLng _position){
    final MarkerId markerDriver = MarkerId("driver");
    final Marker marker = Marker(
      markerId: markerDriver,
      position: _position,
      icon: _taxiIcon,
      draggable: false,
      rotation: 0.0,
      consumeTapEvents: true,
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );
    setState(() {
      markers[markerDriver] = marker;
    });
  }

  dialogInfo(){
    return CustomDialogInfo(
      title: "Information",
      body: "Trip completed. Review your trip now!.",
      onTap: (){
        _waitForDriver != null ?? _waitForDriver.cancel();
        Navigator.of(context).pop();
        Navigator.pushNamed(context, '/review_trip');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
//    _createMarkerImageFromAsset(context);
    _createMarkerImageFromAsset(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              _ticketInfo == null? 10.536421 : double.parse(_ticketInfo["plat"]),
                              _ticketInfo == null? -61.311951 : double.parse(_ticketInfo["plng"])),
                          zoom: 13,
                        ),
                        markers: Set<Marker>.of( markers.values),
                        polylines: Set<Polyline>.of(polyLines.values),
                      )
                  ),
                  isLoading == true ?
                  Container(
                      height: 200.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            child: LoadingBuilder(),
                          )
                        ],
                      )
                  ): hasDriver == true ?  driver(context) :
                  ticket(context),
                ],
              ),
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      centerTitle: true,
                      leading: FlatButton(
                          onPressed: () {
                            if (_waitForDriver != null) {
                              _waitForDriver.cancel();
                            }
                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                          },
                          child: Icon(FontAwesomeIcons.arrowAltCircleLeft,color: blackColor,)
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget ticket(BuildContext context){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.grey,
            child: Column(
              children: <Widget>[
                Container(
                  color: whiteColor,
                  height: 60.0,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Distance",style: textGrey,),
                            Text(distance != null ? distance : "0 km",style: textStyle,),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
                        width: 1.0,
                        height: 30.0,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Time",style: textGrey,),
                            Text(duration != null ? duration : "0 mins",style: textStyle,),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
                        width: 1.0,
                        height: 30.0,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      Expanded(
                          flex: 4,
                          child: Column(
                            children: <Widget>[
                              Text("Cost",style: textGrey,),
                              Text(cost != null ? "\$ " + cost.toStringAsFixed(2) : "\$ 0.00",style: textStyle,)
                            ],
                          )
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1.0,
                  color: greyColor,
                ),
                new Container(
                  color: whiteColor,
                  padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          flex: 5,
                          child: new GestureDetector(
                              onTap: () {
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("PICK UP".toUpperCase(),style: textGreyBold,),
                                  Text(_ticketInfo == null? "" : _ticketInfo["pickup"],style: textStyle,),
                                ],
                              )
                          )
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
                        width: 1.0,
                        height: 30.0,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      new Expanded(
                        flex: 3,
                        child: new GestureDetector(
                            onTap: () {},
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text("PICK UP TIME".toUpperCase(),style: textGreyBold,),
                                Text(_ticketInfo == null? "" : _ticketInfo["timesch"],style: textStyle,),
                              ],
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width - 50.0,
              height: 40.0,
              child: RaisedButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                elevation: 0.0,
                color: greyColor2,
                child: new Text('Awaiting Driver',style: headingWhite,
                ),
                onPressed: (){
                  //handSubmit();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget driver(BuildContext context){
    return Container(
      padding: EdgeInsets.only(left: 8.0,right: 8.0,top: 10.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  height: 50.0,
                  width: 50.0,
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(100.0),
                    child: new ClipRRect(
                        borderRadius: new BorderRadius.circular(100.0),
                        child: new Container(
                            height: 50.0,
                            width: 50.0,
                            child: driverInfo == null?  Image.network(Config.userImageUrl + "-1",fit: BoxFit.cover, height: 100.0,width: 100.0,) : Image.network(Config.userImageUrl + "" + driverInfo["id"], fit: BoxFit.cover, height: 100.0,width: 100.0,)
                        )
                    ),
                  ),
                ),
              Expanded(
                flex: 5,
                child: Container(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(driverInfo == null? "Driver Name" : driverInfo["name"],style: headingBlack,),
                      Text(driverInfo == null? "Vehicle " : driverInfo["vehicle"],style: textGrey,),
                      Text(driverInfo == null? "Reg# " : driverInfo["registration"],style: textGrey,)
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(100.0),),
                        ),
                        child: IconButton(
                          icon: Icon(FontAwesomeIcons.facebookMessenger,color: whiteColor),
                          onPressed: (){
                            Navigator.of(context).push(new MaterialPageRoute<Null>(
                                builder: (BuildContext context) {
                                  return ChatScreen();
                                },
                                fullscreenDialog: true));
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 5.0),),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(100.0),),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.phone,color: whiteColor),
                          onPressed: (){
                            if (_currentUser != null) {
                              launch("tel:+1" + _currentUser.contact);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ],
          ),
          Divider(),
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Distance",style: textGrey,),
                    Text(distance != null ? distance : "0 km",style: textStyle,),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
                width: 1.0,
                height: 30.0,
                color: Colors.grey.withOpacity(0.4),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Time",style: textGrey,),
                    Text(duration != null ? duration : "0 mins",style: textStyle,),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
                width: 1.0,
                height: 30.0,
                color: Colors.grey.withOpacity(0.4),
              ),
              Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      Text(cost != null ? "\$ " + cost.toStringAsFixed(2) : "\$ 0.00",style: headingBlack,)
                    ],
                  )
              ),
            ],
          ),
          Divider(),
          isConfirmed == false ?
            ButtonTheme(
              minWidth: MediaQuery.of(context).size.width,
              height: 45.0,
              child: RaisedButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                elevation: 0.0,
                color: primaryColor,
                child: new Text('Confirm',style: headingWhite,
                ),
                onPressed: (){
                  _confirm();
                },
              ),
            ):
          isComplete == false ?
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width,
            height: 45.0,
            child: RaisedButton(
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
              elevation: 0.0,
              color: primaryColor,
              child: new Text('Cancel',style: headingWhite,
              ),
              onPressed: (){
                _cancel();
              },
            ),
          ):
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width,
            height: 45.0,
            child: RaisedButton(
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
              elevation: 0.0,
              color: primaryColor,
              child: new Text('Review',style: headingWhite,
              ),
              onPressed: (){
                Navigator.pushNamed(context, '/review_trip');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }
}
