import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:riddim_app/Components/historyTrip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class CardNew extends StatefulWidget {
  //final String id;

  //HistoryDetail({this.id});

  @override
  _CardNewState createState() => _CardNewState();
}

class _CardNewState extends State<CardNew> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String yourReview;
  double ratingScore;
  User _currentUser;
  TextEditingController _reviewController;

  String _cardId = "-1";
  String name = "";
  String number = "";
  String year = "";
  String month = "";
  String cvv = "";
  List<Map<String, dynamic>> defaults = [{"id": '1',"name" : 'YES',},{"id": '0',"name" : 'NO',}];
  String selectedDefault;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    setState(() {
      _currentUser = user;
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

    final success = await userRepository.saveVoucher(
      id: _cardId,
      token: _currentUser.userid,
      voucher: name,
    );

    if(success["success"]) {
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

      Navigator.of(context).pushReplacementNamed('/paymentmethod');
      Navigator.popAndPushNamed(context, '/paymentmethod');
    } else {
      Fluttertoast.showToast(
          msg: success["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Voucher',
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
          child: Text('SAVE',style: headingWhite,
          ),
          onPressed: (){
            _submit();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            color: greyColor,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Center(
                  child: Stack(
                    children: <Widget>[
                      Material(
                        elevation: 10.0,
                        borderRadius: BorderRadius.circular(15.0),
                        child: new ClipRRect(
                            borderRadius: new BorderRadius.circular(15.0),
                            child: new Container(
                              height: 150.0,
                              width: 150.0,
                              child: Image.asset("assets/image/wipay.png",fit: BoxFit.cover, height: 150.0,width: 150.0,),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Form(
                  key: formKey,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    color: whiteColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  style: textStyle,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      prefixIcon: Icon(Icons.card_membership,
                                        color: Color(getColorHexFromStr('#FEDF62')), size: 20.0,),
                                      /*suffixIcon: IconButton(
                                                                icon: Icon(CupertinoIcons.clear_thick_circled,color: greyColor2,),
                                                                onPressed: (){
                                                                },
                                                              ),*/
                                      contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                      hintText: 'WiPay Voucher #',
                                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                  ),
                                  controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                      text: name,
                                      selection: new TextSelection.collapsed(
                                          offset: 11),
                                    ),
                                  ),
                                  onChanged: (String _name) {
                                    name = _name;

                                  },
                                ),
                              )
                            ],
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
