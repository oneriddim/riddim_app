import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:riddim_app/Components/historyTrip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class CardNew_CC extends StatefulWidget {
  //final String id;

  //HistoryDetail({this.id});

  @override
  _CardNewStateCC createState() => _CardNewStateCC();
}

class _CardNewStateCC extends State<CardNew_CC> {
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

    final success = await userRepository.saveCard(
      card: _cardId,
      token: _currentUser.userid,
      name: name,
      number: number,
      month: month,
      year: year,
      cvv: cvv,
      def: selectedDefault,
    );

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

      Navigator.of(context).pushReplacementNamed('/paymentmethod');
      Navigator.popAndPushNamed(context, '/paymentmethod');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Card',
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
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "Name on Card",
                                    style: textStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  style: textStyle,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      fillColor: whiteColor,
                                      labelStyle: textStyle,
                                      hintStyle: TextStyle(color: Colors.white),
                                      counterStyle: textStyle,
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white))
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
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "Card #",
                                    style: textStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  style: textStyle,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      fillColor: whiteColor,
                                      labelStyle: textStyle,
                                      hintStyle: TextStyle(color: Colors.white),
                                      counterStyle: textStyle,
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white))
                                  ),
                                  controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                      text: number,
                                      selection: new TextSelection.collapsed(
                                          offset: 11),
                                    ),
                                  ),
                                  onChanged: (String _number) {
                                    number = _number;

                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "Expiry Month",
                                    style: textStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  style: textStyle,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: "MM",
                                      fillColor: whiteColor,
                                      labelStyle: textStyle,
                                      hintStyle: TextStyle(color: Colors.white),
                                      counterStyle: textStyle,
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white))
                                  ),
                                  controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                      text: month,
                                      selection: new TextSelection.collapsed(
                                          offset: 11),
                                    ),
                                  ),
                                  onChanged: (String _month) {
                                    month = _month;

                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "Expiry Year",
                                    style: textStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  style: textStyle,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: "YY",
                                      fillColor: whiteColor,
                                      labelStyle: textStyle,
                                      hintStyle: TextStyle(color: Colors.white),
                                      counterStyle: textStyle,
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white))
                                  ),
                                  controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                      text: year,
                                      selection: new TextSelection.collapsed(
                                          offset: 11),
                                    ),
                                  ),
                                  onChanged: (String _year) {
                                    year = _year;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "CVV",
                                    style: textStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  style: textStyle,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      fillColor: whiteColor,
                                      labelStyle: textStyle,
                                      hintStyle: TextStyle(color: Colors.white),
                                      counterStyle: textStyle,
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white))
                                  ),
                                  controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                      text: cvv,
                                      selection: new TextSelection.collapsed(
                                          offset: 11),
                                    ),
                                  ),
                                  onChanged: (String _cvv) {
                                    cvv = _cvv;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "Is Default Card",
                                    style: textStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: new DropdownButtonHideUnderline(
                                    child: Container(
                                      // padding: EdgeInsets.only(bottom: 12.0),
                                      child: new InputDecorator(
                                        decoration: const InputDecoration(
                                        ),
                                        isEmpty: selectedDefault == null,
                                        child: new DropdownButton<String>(
                                          hint: new Text("Default?",style: textStyle,),
                                          value: selectedDefault,
                                          isDense: true,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              selectedDefault = newValue;
                                              print(selectedDefault);
                                            });
                                          },
                                          items: defaults.map((value) {
                                            return new DropdownMenuItem<String>(
                                              value: value['id'],
                                              child: new Text(value['name'],style: textStyle,),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    )
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
