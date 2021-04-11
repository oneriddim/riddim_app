import 'package:flutter/material.dart';
import 'package:riddim_app/Components/customDialogConfirm.dart';
import 'package:riddim_app/Components/customDialogInfo.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/Menu/Menu.dart';
import 'package:riddim_app/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail.dart';

class NotificationScreens extends StatefulWidget {
  @override
  _NotificationScreensState createState() => _NotificationScreensState();
}

class _NotificationScreensState extends State<NotificationScreens> {
  final userRepository = KonnectRepository();
  final String screenName = "NOTIFICATIONS";
  User _currentUser;

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
  }

  navigateToDetail(String id){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationDetail(id: id,)));
  }

  confirmDelete(){
    return CustomDialogConfirm(
      title: "Confirm Delete",
      body: "Are you sure ?",
      onPressed: () {
        Navigator.of(context).pop();
        print("deleted");
        },
      buttonTitle: "Ok",
    );
  }

  dialogInfo(){
    return CustomDialogInfo(
      title: "Information",
      body: "Delete successful",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification',style: TextStyle(color: blackColor),),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.restore_from_trash,color: blackColor,),
                onPressed: (){
                  print('delete all');
                  showDialog(context: context, child: confirmDelete());
                }
            )
          ]
      ),
        drawer: _currentUser == null? new MenuScreensDefault(activeScreenName: screenName) : new MenuScreens(activeScreenName: screenName, user: _currentUser),
        body: new ListView.builder(
            itemCount: 5,
            itemBuilder: (BuildContext context, int index){
              return Container(
                color: greyColor,
                child: GestureDetector(
                    onTap: (){
                      print('$index');
                      navigateToDetail(index.toString());
                    },
                    child: notificationItem()
                )
              );
            }
        )
    );
  }

  Widget notificationItem(){
    return new Container(
        margin: EdgeInsets.all(10.0),
        color: whiteColor,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Expanded(
                flex: 1,
                child: new Container(
                    child: new Column(
                      children: <Widget>[
                        new Text("12/10"),
                        new Text("12:00")
                      ],
                    )
                )
            ),
            new Container(width: 1.0,height: 20.0,color: primaryColor,),
            new Expanded(
                flex: 5,
                child: new Container(
                  height: 65.0,
                  padding: EdgeInsets.all(8.0),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text("Flutter is Google's mobile app SDK for crafting high-quality native interfaces on iOS and ",style: textBoldBlack,overflow: TextOverflow.ellipsis,),
                      new Container(
                          child: new Text("Flutter works with existing code, is used by developers and organizations around the world, and is free and open source.",style: textStyle,overflow: TextOverflow.ellipsis,)
                      )
                    ],
                  ),
                )
            ),
          ],
        )
    );
  }
}
