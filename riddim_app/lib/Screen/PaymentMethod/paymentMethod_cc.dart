import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/Menu/Menu.dart';
import 'package:riddim_app/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app/Screen/PaymentMethod/addcard.dart';
import 'package:riddim_app/Screen/PaymentMethod/card.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethod_CC extends StatefulWidget {
  @override
  _PaymentMethodStateCC createState() => _PaymentMethodStateCC();
}

class _PaymentMethodStateCC extends State<PaymentMethod_CC> {
  final userRepository = KonnectRepository();
  final String screenName = "PAYMENT";
  User _currentUser;
  List<dynamic> _listRequest = List<dynamic>();

  @override
  initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    setState(() {
      _currentUser = user;
    });

    getPaymentCards();
  }

  void getPaymentCards() async {
    if (_currentUser != null) {
      Fluttertoast.showToast(
          msg: "Getting Cards",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );

      final results = await userRepository.getPaymentCards(
          token: _currentUser.userid
      );
      setState(() {
        _listRequest = results;
      });
    }
  }
  navigateToDetail(String card) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("card", card);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CardDetail()));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment method',style: TextStyle(color: blackColor),),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),

      ),
      drawer: _currentUser == null? new MenuScreensDefault(activeScreenName: screenName) : new MenuScreens(activeScreenName: screenName, user: _currentUser),
      body: Container(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        color: greyColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                  builder: (BuildContext context) {
                    return CardNew();
                  },
                ));
              },
              child: Container(
                padding: EdgeInsets.only(top: 10.0,bottom: 10.0,left: 10.0,right: 10.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x88999999),
                        offset: Offset(0, 5),
                        blurRadius: 5.0,
                      ),
                    ]),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Icon(FontAwesomeIcons.wallet,color: blackColor,),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Text("Add a new card",style: textBoldBlack,)
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Icon(Icons.arrow_forward_ios,color: blackColor,),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 30.0,bottom: 10.0),
              child: Text('CREDIT CARDS',style: textStyle,),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _listRequest.length,
                itemBuilder: (BuildContext context, index){
                  return Container(
                      color: greyColor,
                      child: GestureDetector(
                          onTap: () {
                            print('$index');
                            navigateToDetail(_listRequest[index]["id"]);
                          },
                          child: creditCard("assets/image/image_" + _listRequest[index]['cardtype'] + ".png",_listRequest[index]['card'],_listRequest[index]['expiry']))); //creditCard("assets/image/image_" + _listRequest[index]['cardtype'] + ".png",_listRequest[index]['card'],_listRequest[index]['expiry']);
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget creditCard(String image, String numberCard, String nameCard){
    return Container(
      padding: EdgeInsets.only(top: 10.0,bottom: 10.0,left: 10.0,right: 10.0),
      decoration: BoxDecoration(
          color: Colors.white,
//          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Color(0x88999999),
              offset: Offset(0, 5),
              blurRadius: 5.0,
            ),
          ]),
      child: Row(
        children: <Widget>[
          Container(
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: greyColor2,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Image.asset(image,height: 45.0,)
          ),
          Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(numberCard,style: textBoldBlack,),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                ),
                Text(nameCard,style: textGrey,)
              ],
            ),
          )
        ],
      ),
    );
  }
}
