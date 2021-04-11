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

class DirectionsScreen2 extends StatefulWidget {
  final List<Map<String, dynamic>> dataFrom;
  final List<Map<String, dynamic>> dataTo;

  DirectionsScreen2({this.dataFrom,this.dataTo});

  @override
  _DirectionsScreen2State createState() => _DirectionsScreen2State();
}

class _DirectionsScreen2State extends State<DirectionsScreen2> {
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
  bool isLoading = false;
  bool isResult = false;
  bool isScheduled = false;
  LatLng positionDriver;
  bool isConfirmed = false;
  bool isComplete = false;
  var apis = Apis();
  List<Routes> routesData;
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();

  User _currentUser;
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
    _getCurrentUser();
    addMakers();
    getRouter();
//    _createPoints();
  }

  @override
  void dispose() {
    super.dispose();
    _waitForDriver != null ?? _waitForDriver.cancel();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    setState(() {
      _currentUser = user;
    });

  }

  addMakers(){
    checkPlatform ? print('ios'): print("adnroid");
    final MarkerId markerIdFrom = MarkerId("from_address");
    final MarkerId markerIdTo = MarkerId("to_address");


    var _dataFrom =  widget.dataFrom;
    var _dataTo =  widget.dataTo;

    final Marker marker = Marker(
      markerId: markerIdFrom,
      position: LatLng(_dataFrom[0]['lat'], _dataFrom[0]['long']),
      infoWindow: InfoWindow(title: _dataFrom[0]['name'], snippet: _dataFrom[0]['address']),
      icon:  checkPlatform ? BitmapDescriptor.fromAsset("assets/image/gps_point_24.png") : BitmapDescriptor.fromAsset("assets/image/gps_point.png"),
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );

    final Marker markerTo = Marker(
      markerId: markerIdTo,
      position: LatLng(_dataTo[0]['lat'], _dataTo[0]['long']),
      infoWindow: InfoWindow(title: _dataTo[0]['name'], snippet: _dataTo[0]['address']),
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
    LatLng _fromLocation = LatLng(widget?.dataFrom[0]['lat'], widget?.dataFrom[0]['long']);
    LatLng _toLocation = LatLng(widget?.dataTo[0]['lat'], widget?.dataTo[0]['long']);

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

  ///Real-time test of driver's location
  ///My data is demo.
  ///This function works by: every 5 or 2 seconds will request for api and after the data returns,
  ///the function will update the driver's position on the map.

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

      _updateMyLocation();

      if (driverTracker["completed"]) {
        setState(() {
          t.cancel();
          isComplete = true;
          showDialog(context: context, builder: (BuildContext context) { return dialogInfo(); },);
        });
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

  dialogOption(){
    return CustomDialogInput(
      title: "Option",
      body: "",
      buttonName: "Confirm",
      inputValue: TextFormField(
        style: textStyle,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          //border: InputBorder.none,
          hintText: "Ex: I'm standing in front of the bus stop...",
          // hideDivider: true
        ),
        controller:
        new TextEditingController.fromValue(
          new TextEditingValue(
            text: notes,
            selection: new TextSelection.collapsed(offset: 11),
          ),
        ),
        onChanged: (String _notes) {
          notes = _notes;
        },
      ),
      onPressed: (){print(Navigator.of(context).pop());print('Option');},
    );
  }

  dialogPromoCode(){
    return CustomDialogInput(
      title: "Promo Code",
      body: "",
      buttonName: "Confirm",
      inputValue: TextFormField(
        style: textStyle,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          //border: InputBorder.none,
          hintText: "Enter promo code",
          // hideDivider: true
        ),
        controller:
            new TextEditingController.fromValue(
              new TextEditingValue(
                text: promo,
                selection: new TextSelection.collapsed(offset: 11),
              ),
            ),
        onChanged: (String _promo) {
          promo = _promo;
          },
      ),
      onPressed: (){print(Navigator.of(context).pop());print('Option');},
    );
  }

  handSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("Submit");
    setState(() {
      isLoading = true;
    });

    //DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(scheduled);
    final created = await userRepository.addTicket(
        token: _currentUser.userid,
        date: formattedDate,
        pickup: widget?.dataFrom[0]['name'] + " " + widget?.dataFrom[0]['address'],
        plat: widget?.dataFrom[0]['lat'],
        plng: widget?.dataFrom[0]['long'],
        dropoff:  widget?.dataTo[0]['name'] + " " + widget?.dataTo[0]['address'],
        dlat: widget?.dataTo[0]['lat'],
        dlng: widget?.dataTo[0]['long'],
        dist: distanceAct.toString(),
        dur: durationAct.toString(),
      notes: notes,
      promo: promo
    );

    LatLng _fromLocation = LatLng(widget?.dataFrom[0]['lat'], widget?.dataFrom[0]['long']);
    LatLng _toLocation = LatLng(widget?.dataTo[0]['lat'], widget?.dataTo[0]['long']);

    // set timer and wait for acceptance from driver
    if (created["success"]) {

      DateTime date = DateTime.now();
      date.add(new Duration(minutes: 45));
      if (scheduled.isAfter(date)) {
        setState(() {
          isLoading = false;
          isResult = false;
          isScheduled = true;
        });
      } else {
        _ticketId = created["id"];
        prefs.setString("ticket", _ticketId);

        _waitForDriver = Timer.periodic(Duration(seconds: 10), (Timer t) async {
          final accepted = await userRepository.isTicketAccepted(ticket: _ticketId, token: _currentUser.userid);
          if (accepted["success"]) {
            setState(() {
              driverInfo = accepted["data"];
              _waitForDriver.cancel();
              isLoading = false;
              isResult = true;
            });
          }
        });

      }
    } else {
      Fluttertoast.showToast(
          msg: created["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
      showDialog(context: context, builder: (BuildContext context) { return dialogBooking(created["message"]); },);

      setState(() {
        isLoading = false;
        isResult = false;
        isScheduled = false;
      });
    }
  }

  dialogInfo(){
    return CustomDialogInfo(
      title: "Information",
      body: "Trip completed. Review your trip now!.",
      onTap: () {
        _waitForDriver != null ?? _waitForDriver.cancel();
        Navigator.of(context).pop();
        Navigator.pushNamed(context, '/review_trip');
      },
    );
  }

  dialogBooking(String message){
    return CustomDialogInfo(
      title: "Information",
      body: message,
      onTap: () {
        Navigator.of(context).pop();
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
                          target: LatLng(widget.dataFrom[0]['lat'], widget.dataFrom[0]['long']),
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
                  ): isScheduled == true ? schedule(context) :
                      isResult == true ?  result(context) :
                  booking(context),
                ],
              ),
              Positioned(
                  top: 40,
                  right: 10,
                  child: Container(
                    height: 40.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100.0),),
                    ),
                    child:  FlatButton.icon(
                      onPressed: () {
                      },
                      icon: Icon(Icons.departure_board,size: 20.0,color: blackColor,),
                      label: Text(DateFormat('EEE, MMM d hh:mm aaa').format(scheduled)),
                    ),
                  )
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

  Widget booking(BuildContext context){
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
                        child: Container(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Icon(FontAwesomeIcons.car),
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      //Text('GrabTaxi',style: textStyle,),
                                      Text('Near by you',style: textStyle,),
                                    ],
                                  ),
                                )

                              ],
                            )
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Text(distance != null ? distance : "0 km",style: textGrey,),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(cost != null ? "\$ " + cost.toStringAsFixed(2) : "\$ 0.00",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              Text(duration != null ? duration : "0 mins",style: textGrey,),
                            ],
                          ),
                        )
                      )
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
                          flex: 3,
                          child: new GestureDetector(
                              onTap: () {
                                showCupertinoModalPopup<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return _buildBottomPicker(
                                      CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.dateAndTime,
                                        initialDateTime: scheduled,
                                        minimumDate: scheduled.isBefore(DateTime.now()) ? scheduled : DateTime.now(),
                                        maximumDate: DateTime.now().add(new Duration(days: 3)),
                                        onDateTimeChanged: (DateTime newDateTime) {
                                          setState(() {
                                            scheduled = newDateTime;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child:  new Column(
                                children: <Widget>[
                                  new Icon(FontAwesomeIcons.clock,color: greyColor2,),
                                  new Text("Schedule",style: textGrey,),
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
                            onTap: () =>showDialog(context: context,  builder: (BuildContext context) { return dialogOption(); }),
                            child: new Column(
                              children: <Widget>[
                                new Icon(FontAwesomeIcons.cogs,color: greyColor2,),
                                new Text("Options",style: textGrey,),
                              ],
                            )
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
                        width: 1.0,
                        height: 30.0,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      new Expanded(
                        flex: 3,
                        child: GestureDetector(
                            onTap: () => showDialog(context: context,  builder: (BuildContext context) { return dialogPromoCode(); }),
                            child: new Column(
                              children: <Widget>[
                                new Icon(FontAwesomeIcons.gifts,color: greyColor2,),
                                new Text("Promo",style: textGrey,),
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
            padding: EdgeInsets.only(top: 10.0,bottom: 10.0),
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width - 50.0,
              height: 45.0,
              child: RaisedButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                elevation: 0.0,
                color: primaryColor,
                child: new Text('Book Ride',style: headingWhite,
                ),
                onPressed: (){
                  handSubmit();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget schedule(BuildContext context){
    return Container(
      padding: EdgeInsets.only(left: 8.0,right: 8.0,top: 10.0),
      child: Column(
        children: <Widget>[
          Row(
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
          Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("PICK UP".toUpperCase(),style: textGreyBold,),
                        Text(widget?.dataFrom[0]['name'],style: textStyle,),

                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("PICK UP TIME".toUpperCase(),style: textGreyBold,),
                        Text(scheduled == null? "" : DateFormat('EEE, MMM d, hh:mm aaa').format(scheduled),style: textStyle,),
                      ],
                    ),
                  ),
                ],
              )
          ),
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width,
            height: 45.0,
            child: RaisedButton(
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
              elevation: 0.0,
              color: prefix0.blackColor,
              child: new Text('DONE',style: headingWhite,
              ),
              onPressed: (){
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget result(BuildContext context){
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
                _waitForDriver != null ?? _waitForDriver.cancel();
                Navigator.of(context).pop();
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
