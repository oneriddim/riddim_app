import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Components/customDialogInfo.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:riddim_app/Components/historyTrip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class CardDetail extends StatefulWidget {
  //final String id;

  //HistoryDetail({this.id});

  @override
  _CardDetailState createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String yourReview;
  double ratingScore;
  User _currentUser;
  Map _cardInfo;

  String _cardId = "-1";
  String name = "";
  String number = "";


  @override
  void initState() {
    super.initState();
    _getCardInfo();
  }

  Future<void> _getCardInfo() async {
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
    _cardId = prefs.get("card");
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    final info = await userRepository.voucher(card: _cardId, token: user.userid);

    setState(() {
      _currentUser = user;
      if (info.length > 0) {
        _cardInfo = info["data"];
        name = _cardInfo["name"];
        number = _cardInfo["amount"];
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
      prefs.remove("card");

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

  _delete() async {
    Fluttertoast.showToast(
        msg: "Please wait..",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );

    final success = await userRepository.deleteVoucher(
      card: _cardId,
      token: _currentUser.userid,
    );

    if(success) {
      Fluttertoast.showToast(
          msg: "Deleted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("card");

      Navigator.of(context).pushReplacementNamed('/paymentmethod');
      Navigator.popAndPushNamed(context, '/paymentmethod');
    }

  }

  dialogDelete(){
    return CustomDialogInfo(
      title: "Delete Card",
      body: "Are you sure you want to delete card?",
      onTap: (){
        _delete();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Card Details' ,
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.delete,color: blackColor,),
                onPressed: (){ showDialog(context: context,  builder: (BuildContext context) { return dialogDelete(); });}
            )
          ]
      ),
      bottomNavigationBar: ButtonTheme(
        minWidth: screenSize.width,
        height: 45.0,
        child: RaisedButton(
          elevation: 0.0,
          color: primaryColor,
          child: Text('UPDATE AMOUNT',style: headingWhite,
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
                              child: Image.asset("assets/image/wipay.png", width: 100.0,),
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
                                      child: Text(name,style: textBoldBlack,),
                                    ),
                                    Container(
                                        child: Text("",style: heading18Black,)
                                    ),

                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                ],
                              ),
                            ],
                          )
                      )
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
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  enabled: false,
                                  style: textStyle,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      prefixIcon: Icon(Icons.attach_money,
                                        color: Color(getColorHexFromStr('#FEDF62')), size: 20.0,),
                                      /*suffixIcon: IconButton(
                                                                icon: Icon(CupertinoIcons.clear_thick_circled,color: greyColor2,),
                                                                onPressed: (){
                                                                },
                                                              ),*/
                                      contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                      hintText: 'WiPay Voucher Amount',
                                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                  ),
                                  controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                      text: number,
                                      selection: new TextSelection.collapsed(
                                          offset: 11),
                                    ),
                                  ),
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
