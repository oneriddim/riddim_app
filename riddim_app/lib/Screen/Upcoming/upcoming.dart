import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:riddim_app/Screen/Menu/Menu.dart';
import 'package:riddim_app/Components/historyTrip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail.dart';

class UpcomingScreen extends StatefulWidget {
  @override
  _UpcomingScreenState createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final userRepository = KonnectRepository();
  final String screenName = "UPCOMING";
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

    _getUpcomingTickets();
  }

  void _getUpcomingTickets() async {
    if (_currentUser != null) {
      Fluttertoast.showToast(
          msg: "Getting Upcoming",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );

      final results = await userRepository.getUpcomingTickets(
          token: _currentUser.userid,
          date: ""
      );
      setState(() {
        _listRequest = results;
      });
    }
  }

  navigateToDetail(String ticket) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ticket", ticket);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpcomingDetail()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new ListView.builder(
          itemCount: _listRequest == null ? 0 : _listRequest.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                color: greyColor,
                child: GestureDetector(
                    onTap: () {
                      print('$index');
                      navigateToDetail(_listRequest[index]["id"]);
                    },
                    child: historyItem(index)));
          }),
    );
  }

  Widget historyItem(int index) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      color: whiteColor,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text("\$" + _listRequest[index]['price'], style: textBoldBlack,),
                ),
                Container(
                  child: Text(_listRequest[index]['date'], style: textBoldBlack,),
                ),
              ],
            ),
          ),
          Container(
            child: HistoryTrip(
              fromAddress: _listRequest[index]['pickup'],
              toAddress: _listRequest[index]['dropoff'],
            ),
          ),
        ],
      ),
    );
  }
}
