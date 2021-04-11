import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:riddim_app/Components/historyTrip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class UpcomingDetail extends StatefulWidget {
  //final String id;

  //HistoryDetail({this.id});

  @override
  _UpcomingDetailState createState() => _UpcomingDetailState();
}

class _UpcomingDetailState extends State<UpcomingDetail> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String yourReview;
  double ratingScore;
  User _currentUser;
  Map _ticketInfo;
  String _ticketId;
  TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _getTicketInfo();
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
        _ticketInfo = info["data"];
        _reviewController = new TextEditingController(text: _ticketInfo["review"]);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _submit() async {
    Fluttertoast.showToast(
        msg: "Please wait..",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );

    formKey.currentState.save();
    final success = await userRepository.cancelTicket(ticket: _ticketId,
        token: _currentUser.userid);

    if(success) {
      Fluttertoast.showToast(
          msg: "Cancelled",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("ticket");

      Navigator.of(context).pushReplacementNamed('/mytrips');
      Navigator.popAndPushNamed(context, '/mytrips');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upcoming Trip',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            color: greyColor,
            child: Column(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.all(10.0),
                  color: whiteColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(50.0),
                        child: new ClipRRect(
                            borderRadius: new BorderRadius.circular(50.0),
                            child: new Container(
                                height: 50.0,
                                width: 50.0,
                                child: Image.network(_ticketInfo == null? Config.userImageUrl + "-1"  : Config.userImageUrl + "" + _ticketInfo["driverid"], width: 100.0,),
                            )
                        ),
                      ),
                      Container(
                        width: screenSize.width - 100,
                        padding: EdgeInsets.only(left: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text(_ticketInfo == null? "" : _ticketInfo["name"],style: textBoldBlack,),
                                  ),
                                  Container(
                                      child: Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["cost"],style: heading18Black,)
                                  ),

                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_ticketInfo == null? "" : _ticketInfo["datesch"],style: textBoldBlack,),
                                Text(_ticketInfo == null? "" : _ticketInfo["distance"] + "Km",style: textGrey,)
                              ],
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  color: whiteColor,
                  child: HistoryTrip(
                    fromAddress: _ticketInfo == null? "" : _ticketInfo["pickup"],
                    toAddress: _ticketInfo == null? "" : _ticketInfo["dropoff"],
                  ),
                ),
                new Container(
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.all(10.0),
                  color: whiteColor,
                  child: Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Text("Bill Details", style: textBoldBlack,),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Ride Fare", style: textStyle,),
                            new Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["subtotal"], style: textBoldBlack,),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Taxes", style: textStyle,),
                            new Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["taxes"], style: textBoldBlack,),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0,bottom: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Discount", style: textStyle,),
                            new Text(_ticketInfo == null? "- \$0.00" : "- \$" + _ticketInfo["discount"], style: textBoldBlack,),
                          ],
                        ),
                      ),
                      Container(
                        width: screenSize.width - 50.0,
                        height: 1.0,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Total Bill", style: heading18Black,),
                            new Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["total"], style: heading18Black,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: formKey,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    color: whiteColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*FlutterRatingBar(
                          initialRating: _ticketInfo == null? 0 : double.parse(_ticketInfo["rating"]),
                          fillColor: Colors.amber,
                          borderColor: Colors.amber.withAlpha(50),
                          allowHalfRating: true,
                          itemSize: 30.0,
                          onRatingUpdate: (rating) {
                            ratingScore = rating;
                            print(rating);
                          },
                        ),*/
                        ButtonTheme(
                          minWidth: screenSize.width,
                          height: 45.0,
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                            elevation: 0.0,
                            color: primaryColor,
                            child: new Text('Cancel',style: headingWhite,
                            ),
                            onPressed: (){
                              _submit();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
