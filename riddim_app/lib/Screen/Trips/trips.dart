import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/History/history.dart';
import 'package:riddim_app/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app/Screen/Upcoming/upcoming.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:riddim_app/Screen/Menu/Menu.dart';
import 'package:riddim_app/Components/historyTrip.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripScreen extends StatefulWidget {
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen>  with SingleTickerProviderStateMixin  {
  final userRepository = KonnectRepository();
  final String screenName = "TRIPS";
  User _currentUser;
  TabController _tabController;

  @override
  initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
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
    _tabController.dispose();
    super.dispose();
  }


  navigateToDetail(String ticket) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ticket", ticket);
    //Navigator.of(context).push(MaterialPageRoute(builder: (context) => HistoryDetail()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Trips',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab( child: Text ("History", style: TextStyle(color: blackColor),)),
            Tab( child: Text ("Upcoming", style: TextStyle(color: blackColor),)),
          ],
        ),
      ),
      drawer: _currentUser == null? new MenuScreensDefault(activeScreenName: screenName) : new MenuScreens(activeScreenName: screenName, user: _currentUser),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          HistoryScreen(),
          UpcomingScreen(),
        ],
      )
    );
  }
}
