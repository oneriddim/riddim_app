import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class HistoryDetail extends StatefulWidget {
  //final String id;

  //HistoryDetail({this.id});

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
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
        _reviewController = new TextEditingController(text: _ticketInfo["review_p"]);
      }
    });
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
    final success = await userRepository.saveTicketReview(ticket: _ticketId,
        token: _currentUser.userid,
        review: yourReview,
        rating: ratingScore);

    if(success) {
      Fluttertoast.showToast(
          msg: "Saved",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("ticket");

      Navigator.of(context).pushReplacementNamed('/history');
      Navigator.popAndPushNamed(context, '/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      bottomNavigationBar: ButtonTheme(
        minWidth: screenSize.width,
        height: 45.0,
        child: RaisedButton(
          elevation: 0.0,
          color: primaryColor,
          child: Text('Submit',style: headingWhite,
          ),
          onPressed: (){
            _submit();
          },
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Container(
              color: greyColor,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: CachedNetworkImage(
                              imageUrl: _ticketInfo == null? Config.userImageUrl + "-1"  : (Config.userImageUrl + "" + _ticketInfo["driverid"]),
                              fit: BoxFit.cover,
                              width: 40.0,
                              height: 40.0,
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(_ticketInfo == null? "" : _ticketInfo["name"],style: textBoldBlack,),
                              Text(_ticketInfo == null? "" : _ticketInfo["datedrop"], style: textGrey,),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    /*Container(
                                      height: 25.0,
                                      padding: EdgeInsets.all(5.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: primaryColor
                                      ),
                                      child: Text('ApplePay',style: textBoldWhite,),
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      height: 25.0,
                                      padding: EdgeInsets.all(5.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: primaryColor
                                      ),
                                      child: Text('Discount',style: textBoldWhite,),
                                    ),*/
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["cost"],style: textBoldBlack,),
                              Text(_ticketInfo == null? "0 Km" : _ticketInfo["distance"] + "Km",style: textGrey,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: whiteColor,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("PICK UP".toUpperCase(),style: textGreyBold,),
                                Text(_ticketInfo == null? "" : _ticketInfo["pickup"],style: textStyle,),

                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("DROP OFF".toUpperCase(),style: textGreyBold,),
                                Text(_ticketInfo == null? "" : _ticketInfo["dropoff"],style: textStyle,),

                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("note".toUpperCase(),style: textGreyBold,),
                                Text(_ticketInfo == null? "" : _ticketInfo["notes"],style: textStyle,),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5.0,bottom: 5.0),
                    padding: EdgeInsets.all(10),
                    color: whiteColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Bill Details".toUpperCase(), style: textGreyBold,),
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
                              new Text(_ticketInfo == null? "-\$0.00" : "-\$" + _ticketInfo["discount"], style: textBoldBlack,),
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
                              new Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["cost"], style: heading18Black,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: formKey,
                    child: Container(
                      //margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.all(10.0),
                      color: whiteColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RatingBar(
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            initialRating:  _ticketInfo == null? 0 : double.parse(_ticketInfo["rating_p"]),
                            itemSize: 20.0,
                            itemCount: 5,
                            allowHalfRating: true,
                            glowColor: Colors.white,
                            onRatingUpdate: (rating) {
                              ratingScore = rating;
                              print(rating);
                            },
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                              height: 100.0,
                              child: TextField(
                                style: textStyle,
                                decoration: InputDecoration(
                                  hintText: 'Write a review',
//                                hintStyle: TextStyle(
//                                  color: Colors.black38,
//                                  fontFamily: 'Akrobat-Bold',
//                                  fontSize: 16.0,
//                                ),
                                  border: OutlineInputBorder(
                                      borderRadius:BorderRadius.circular(5.0)),
                                ),
                                maxLines: 2,
                                controller: _reviewController,
                                keyboardType: TextInputType.multiline,
                                onChanged: (String value) { setState(() => yourReview = value );},
                              ),
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
      ),
    );
  }
}
