import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/MyProfile/profile.dart';
import 'package:riddim_app/Screen/Trips/trips.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:riddim_app/Screen/Login/login.dart';
import 'package:riddim_app/Screen/PaymentMethod/paymentMethod.dart';
import 'package:riddim_app/Screen/Notification/notification.dart';
import 'package:riddim_app/Screen/History/history.dart';
import 'package:riddim_app/Screen/Settings/settings.dart';
import 'package:riddim_app/Screen/MyProfile/myProfile.dart';
import 'package:riddim_app/config.dart';

class MenuItems {
  String name;
  IconData icon;
  MenuItems({this.icon, this.name});
}

class MenuScreens extends StatelessWidget {
  final String activeScreenName;
  final User user;
  final userRepository = KonnectRepository();

  MenuScreens({this.activeScreenName, this.user});

  @override
  Widget build(BuildContext context) {
    _logout() async {
      var logout = await userRepository.logout(token: user.userid);
      if (logout) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => LoginScreen()));

      }
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            margin: EdgeInsets.all(0.0),
            accountName: new Text(user.fullname,style: headingWhite,),
            accountEmail: new Text(user.email),
            currentAccountPicture: new CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.network(Config.userImageUrl + "" + user.userid, width: 100.0,),
            ),
            onDetailsPressed: (){
              Navigator.pop(context);
              Navigator.of(context).push(new MaterialPageRoute<Null>(
                  builder: (BuildContext context) {
                    return Profile();
                  },
                  fullscreenDialog: true));
            },
          ),
          new MediaQuery.removePadding(
            context: context,
            // DrawerHeader consumes top MediaQuery padding.
            removeTop: true,
            child: new Expanded(
              child: new ListView(
                //padding: const EdgeInsets.only(top: 8.0),
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      // The initial contents of the drawer.
                      new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);},
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("HOME") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.home,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Home',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          /*new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamedAndRemoveUntil('/home2', (Route<dynamic> route) => false);},
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("HOME2") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.home,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Home 2',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),*/
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                  new MaterialPageRoute(builder: (context) => PaymentMethod()));
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("PAYMENT") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.wallet,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('My Wallet',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                  new MaterialPageRoute(builder: (context) => TripScreen()));
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("TRIPS") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.carAlt,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('My Trips',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          /*new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                  new MaterialPageRoute(builder: (context) => NotificationScreens()));
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("NOTIFICATIONS") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.bell,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Notifications',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),*/
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                  new MaterialPageRoute(builder: (context) => SettingsScreen()));
                              },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("SETTINGS") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.cogs,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Settings',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              _logout();
                            },
                            child: new Container(
                              height: 60.0,
                              color: whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.signOutAlt,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Logout',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // The drawer's "details" view.
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
