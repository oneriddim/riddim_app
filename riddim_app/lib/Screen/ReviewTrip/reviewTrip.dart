import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:riddim_app/Components/historyTrip.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class ReviewTripScreens extends StatefulWidget {
  @override
  _ReviewTripScreensState createState() => _ReviewTripScreensState();
}

class _ReviewTripScreensState extends State<ReviewTripScreens> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String yourReview;
  double ratingScore;
  User _currentUser;
  String _ticketId;
  Map _ticketInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTicketInfo();
  }

  _getTicketInfo() async {
    Fluttertoast.showToast(
        msg: "Getting details...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ticket = prefs.get("ticket");
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    print(user.userid);
    print(ticket);

    final info = await userRepository.ticket(ticket: ticket, token: user.userid);

    if (info["success"]) {
      setState(() {
        _ticketId = ticket;
        _currentUser = user;
        _ticketInfo = info["data"];
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    _submit() async {
      formKey.currentState.save();

      Fluttertoast.showToast(
          msg: "Please wait...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );

      final success = await userRepository.saveTicketReview(ticket: _ticketId, token: _currentUser.userid, review:  yourReview, rating: ratingScore);
      if (success) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("ticket");
        Fluttertoast.showToast(
            msg: "Saved",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      Navigator.of(context).pushReplacementNamed('/home');
      Navigator.popAndPushNamed(context, '/home');
    }

    _skip() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("ticket");
      formKey.currentState.save();
      Navigator.of(context).pushReplacementNamed('/home');
      Navigator.popAndPushNamed(context, '/home');
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: blackColor),
        elevation: 2.0,
//        centerTitle: true,
        backgroundColor: whiteColor,
        title: Text('Review your trip',style: TextStyle(color: blackColor),),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            color: greyColor,
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  height: 100.0,
                  width: double.infinity,
                  color: primaryColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(_ticketInfo == null? "\$ 0.00" : "\$ " + _ticketInfo["cost"],style: heading35,),
                      ),
                      /*Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Image.asset("assets/image/car1.png",height: 70.0,)
                      ),*/
                      Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(_ticketInfo == null? "": _ticketInfo["datedrop"],style: heading18,),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  color: whiteColor,
                  padding: EdgeInsets.all(10.0),
                  child: HistoryTrip(
                    fromAddress: _ticketInfo == null? "": _ticketInfo["pickup"],
                    toAddress: _ticketInfo == null? "": _ticketInfo["dropoff"],
                  ),
                ),
                Container(
                  color: greyColor,
                  padding: EdgeInsets.all(10.0),
                  child: Material(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: new ClipRRect(
                                        borderRadius: new BorderRadius.circular(100.0),
                                        child: new Container(
                                            height: 100.0,
                                            width: 100.0,
//                      color: Color(getColorHexFromStr('#FDD148')),
                                            child: _ticketInfo == null? Image.network(Config.userImageUrl + "-1",fit: BoxFit.cover, height: 100.0,width: 100.0,) : Image.network(Config.userImageUrl + "" + _ticketInfo["driverid"], fit: BoxFit.cover, height: 100.0,width: 100.0,)
                                        )
                                    ),
                                  ),
                                ),
                                /*RatingBar(
                                  initialRating: 4,
                                  fillColor: Colors.amber,
                                  borderColor: Colors.amber.withAlpha(50),
                                  allowHalfRating: true,
                                  itemSize: 30.0,
                                  onRatingUpdate: (rating) {
                                    setState(() => ratingScore = rating );
                                  },
                                ),*/
                                RatingBar(
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  initialRating: 0,
                                  itemSize: 30.0,
                                  itemCount: 5,
                                  allowHalfRating: true,
                                  glowColor: Colors.white,
                                  onRatingUpdate: (rating) {
                                    setState(() => ratingScore = rating );
                                  },
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: new SizedBox(
                                    height: 100.0,
                                    child: new TextField(
                                      style: new TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Write your review",
                                        hintStyle: TextStyle(
                                          color: Colors.black38,
                                          fontFamily: 'Akrobat-Bold',
                                          fontSize: 16.0,
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius:BorderRadius.circular(5.0)),
                                      ),
                                      maxLines: 2,
                                      keyboardType: TextInputType.multiline,
                                      onChanged: (String value) { setState(() => yourReview = value );},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      )
                  ),
                ),
                Container(
                  color: greyColor,
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: screenSize.width*0.43,
                        height: 45.0,
                        child: OutlineButton(
                            color: blackColor,
                            textColor: blackColor,
                            child: Text('Skip'),
                            onPressed:(){
                              _skip();
                            }
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 30.0),),
                      ButtonTheme(
                        minWidth: screenSize.width*0.43,
                        height: 45.0,
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                          elevation: 0.0,
                          color: primaryColor,
                          child: new Text('Submit',style: headingWhite,
                          ),
                          onPressed: (){
                            _submit();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )

      ),
    );
  }
}
