import 'package:flutter/material.dart';
import 'package:riddim_app/Theme/style.dart';
import 'package:riddim_app/theme/style.dart' as prefix0;

import 'data.dart';

class WalkThroughScreen extends StatelessWidget {

  final ItemsListBuilder itemsListBuilder = new ItemsListBuilder();

  @override
  Widget build(BuildContext context) {
    return (new Scaffold(
      body: new DefaultTabController(
          length: itemsListBuilder.itemList.length,
          child: WalkThroughScreenBuild(
            itemList: itemsListBuilder.itemList,
          )
      ),
    ));
  }
}

class WalkThroughScreenBuild extends StatelessWidget {
  final List<Items> itemList;
  final BuildContext context;

  WalkThroughScreenBuild({this.itemList,this.context});
  _onPressed() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    context = context;
    final TabController controller = DefaultTabController.of(context);
    return new Container(
        color: prefix0.greyColor,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
                child: new TabBarView(
                    children: itemList.map((Items item) {
                      return new Column(
                        key: new ObjectKey(item),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Image.asset(item.image,height: 180.0,),
                          new Text(item.pageNo, style: prefix0.headingBlack,
                          ),
                          new Container(
                            padding: new EdgeInsets.only(left: 60.0, right: 60.0),
                            child: new Text(
                              item.description,
                              style: prefix0.textBoldBlack,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ButtonTheme(
                            minWidth: screenSize.width*0.43,
                            height: 45.0,
                            child: RaisedButton(
                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                              elevation: 0.0,
                              color: primaryColor,
                              child: new Text(item.btnDescription,style: headingWhite,
                              ),
                              onPressed: _onPressed,
                            ),
                          ),
                        ],
                      );
                    }).toList())),
            new Container(
              margin: new EdgeInsets.only(bottom: 32.0),
              child: new TabPageSelector(
                controller: controller,
                selectedColor: prefix0.primaryColor,
              ),
            )
          ],
        )
    );
  }
}