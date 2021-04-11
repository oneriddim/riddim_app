import 'package:flutter/material.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app/Screen/MyProfile/profile.dart';
import 'package:riddim_app/Screen/Reviews/reviews.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:riddim_app/Screen/Menu/Menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:riddim_app/Components/listMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import 'inviteFriends.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final userRepository = KonnectRepository();
  final String screenName = "SETTINGS";
  User _currentUser;

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
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        title: Text('Settings',style: TextStyle(color: blackColor),),
      ),
      drawer: _currentUser != null? new MenuScreens(activeScreenName: screenName, user: _currentUser): new MenuScreensDefault(activeScreenName: screenName),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            color: backgroundColor,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return Profile();
                        },
                    ));
                  },
                  child: Container(
                    color: whiteColor,
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
                    child: Row(
                      //mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(50.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: CachedNetworkImage(
                              imageUrl: _currentUser == null ? Config.userImageUrl + "-1" : Config.userImageUrl + _currentUser.userid,
                              fit: BoxFit.cover,
                              width: 50.0,
                              height: 50.0,
                            ),
                          ),
                        ),
                        Container(
                          width: screenSize.width-70 ,
                          padding: EdgeInsets.only(left: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Text(_currentUser == null ? "" :  _currentUser.fullname,style: textBoldBlack,),
                                    ),
                                    Container(
                                        child: Text("",style: TextStyle(
                                          fontSize: 12,
                                          color: greyColor2
                                        ),)
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_forward_ios,color: CupertinoColors.lightBackgroundGray,)
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
//                ListsMenu(
//                  title: "100 Point * Member",
//                  onPress: (){
//
//                  },
//                ),
                ListsMenu(
                  title: "Reviews",
                  icon: Icons.star,
                  backgroundIcon: Colors.cyan,
                  onPress: (){
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return ReviewScreen();
                      },
                    ));
                  },
                ),
                /*ListsMenu(
                  title: "Invite Friends",
                  icon: Icons.people,
                  backgroundIcon: primaryColor,
                  onPress: (){
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return InviteFriends();
                        },
                        fullscreenDialog: true));
                  },
                ),*/
                /*ListsMenu(
                  title: "Notification",
                  icon: Icons.notifications_active,
                  backgroundIcon: primaryColor,
                  onPress: (){

                  },
                ),*/
                ListsMenu(
                  title: "Terms & Privacy Policy",
                  icon: Icons.description,
                  backgroundIcon: Colors.deepPurple,
                  onPress: (){

                  },
                ),
                ListsMenu(
                  title: "Contact us",
                  icon: Icons.help,
                  backgroundIcon: primaryColor,
                  onPress: (){

                  },
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}
