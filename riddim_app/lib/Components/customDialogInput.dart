import 'package:flutter/material.dart';
import 'package:riddim_app/components/CustomShowDialog.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDialogInput extends StatelessWidget {
  final String title,body, buttonName;
  final Widget inputValue;
  final VoidCallback onPressed;

  CustomDialogInput({
    this.onPressed,
    this.title,
    this.body,
    this.buttonName,
    this.inputValue,
});

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
      content: new Container(
        width: 260.0,
        height: 240.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
         // color: const Color(0xFF9ECFAA),
          borderRadius:
          new BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // dialog top
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Expanded(
                      flex: 4,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                              padding: new EdgeInsets.fromLTRB(16.0,16.0,0.0,0.0),
                              child: new Icon(FontAwesomeIcons.cogs,color: greyColor2,),
                          ),
                        ],
                      )
                  ),
                  new Expanded(
                      flex: 1,
                      child: new GestureDetector(
                        onTap:() => Navigator.pop(context),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              padding: new EdgeInsets.fromLTRB(16.0,10.0,0.0,0.0),
                              child: new Icon(Icons.close,color: greyColor2,),
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ),
            // dialog centre
            new Expanded(
              flex: 3,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 0.0),
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(title != null ? title : '',
                            style: headingBlack,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                  ),
                  new Container(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 0.0),
                      child: new Text(body != null ? body : '',
                        style: heading18Black,
                        //textAlign: TextAlign.center,
                      ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: inputValue,
                  )
                ],
              ),
            ),
            new GestureDetector(
              onTap: onPressed,
              child: new Container(
                width: 220.0,
                height: 50.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: primaryColor,
                    borderRadius:
                    new BorderRadius.only(bottomLeft: new Radius.circular(10.0),bottomRight: new Radius.circular(10.0))
                ),
                child: new Center(
                  child: new Text(
                    buttonName,
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontFamily: "OpenSans",
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
