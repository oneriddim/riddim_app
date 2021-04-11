import 'package:flutter/material.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:riddim_app/Screen/Login/login.dart';
import 'package:riddim_app/Screen/Walkthrough/walkthrough.dart';

class PhoneVerification extends StatefulWidget {
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  TextEditingController controller = TextEditingController();
  String thisText = "";
  int pinLength = 4;

  bool hasError = false;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: blackColor,),
          onPressed: () => Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => LoginScreen())),
        ),
      ),
      body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Container(
              padding: EdgeInsets.fromLTRB(screenSize.width*0.13, 0.0, screenSize.width*0.13, 0.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 10.0),
                      child: Text('Phone Verification',style: heading35Black,),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 0.0),
                      child: Text('Enter your OTP code hear'),
                    ),
                    Container(
                      child: PinCodeTextField(
                        autofocus: true,
                        controller: controller,
                        hideCharacter: false,
                        highlight: true,
                        highlightColor: secondary,
                        defaultBorderColor: blackColor,
                        hasTextBorderColor: primaryColor,
                        maxLength: pinLength,
                        hasError: hasError,
                        maskCharacter: "*",
                        onTextChanged: (text) {
                          setState(() {
                            hasError = false;
                          });
                        },
                        onDone: (text){
                          print("DONE $text");
                        },
                        pinCodeTextFieldLayoutType: PinCodeTextFieldLayoutType.AUTO_ADJUST_WIDTH,
                        wrapAlignment: WrapAlignment.start,
                        pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                        pinTextStyle: heading35Black,
                        pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                        pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
                      ),
                    ),
                    new ButtonTheme(
                      height: 45.0,
                      minWidth: MediaQuery.of(context).size.width-50,
                      child: RaisedButton.icon(
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                        elevation: 0.0,
                        color: primaryColor,
                        icon: new Text(''),
                        label: new Text('VERIFY NOW', style: headingWhite,),
                        onPressed: (){Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(builder: (context) => WalkThroughScreen()));},
                      ),
                    ),
                    new Container(
                        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new InkWell(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: new Text("I didn't get a code",style: textStyleActive,),
                            ),
                          ],
                        )
                    ),
                  ]
              ),
            ),

          )
      ),
    );
  }
}
