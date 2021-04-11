import 'package:flutter/material.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/MyProfile/myProfile.dart';
import 'package:riddim_app/config.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final userRepository = KonnectRepository();
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.mode_edit),
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute<Null>(
                  builder: (BuildContext context) {
                    return MyProfile();
                  },
              ));
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Container(
          color: backgroundColor,
          child: Column(
            children: <Widget>[
              Center(
                child: Stack(
                  children: <Widget>[
                    Material(
                      elevation: 10.0,
                      color: Colors.white,
                      shape: CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              _currentUser == null ? Config.userImageUrl + "-1" : Config.userImageUrl + _currentUser.userid,
                            )
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10.0,
                      left: 25.0,
                      height: 15.0,
                      width: 15.0,
                      child: Container(
                        width: 15.0,
                        height: 15.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: greenColor,
                            border: Border.all(
                                color: Colors.white, width: 2.0)),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _currentUser == null ? "" :  _currentUser.fullname,
                      style: TextStyle( color: blackColor,fontSize: 35.0),
                    ),
                    Text(
                      "",
                      style: TextStyle( color: blackColor, fontSize: 13.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              /*Container(
                color: whiteColor,
                child: LineChartWallet(),
              ),
              SizedBox(height: 20),*/
              Container(
                child: Column(
                  children: <Widget>[
                    /*Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        border: Border(
                          bottom: BorderSide(width: 1.0,color: backgroundColor)
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Name',style: textStyle,),
                          Text(_currentUser == null ? "" :  _currentUser.fullname, style: textGrey,)
                        ],
                      ),
                    ),*/
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                              bottom: BorderSide(width: 1.0,color: backgroundColor)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Phone Number',style: textStyle,),
                          Text(_currentUser == null ? "" :  _currentUser.contact,style: textGrey,)
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                              bottom: BorderSide(width: 1.0,color: backgroundColor)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Email',style: textStyle,),
                          Text(_currentUser == null ? "" :  _currentUser.email,style: textGrey,)
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                              bottom: BorderSide(width: 1.0,color: backgroundColor)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Birthday',style: textStyle,),
                          Text(_currentUser == null ? "" :  _currentUser.dob,style: textGrey,)
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                              bottom: BorderSide(width: 1.0,color: backgroundColor)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Address',style: textStyle,),
                          Text(_currentUser == null ? "" :  _currentUser.address,style: textGrey,)
                        ],
                      ),
                    ),
                  ],
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}
