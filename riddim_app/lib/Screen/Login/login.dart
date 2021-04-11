import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Screen/Home/home.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:riddim_app/Components/validations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import '../../config.dart';
import 'phoneVerification.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool autovalidate = false;
  Validations validations = new Validations();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    _checkLogin() async {
      final FormState form = formKey.currentState;
      if (!form.validate()) {
        autovalidate = true; // Start validating on every change.
      } else {
        form.save();

        //code
        Fluttertoast.showToast(
            msg: "Please wait, checking...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.orangeAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );

        try {
          final token = await userRepository.authenticate(
            username: _usernameController.text,
            password: _passwordController.text,
          );
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('usertoken', token);

          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => HomeScreen()));

        } catch (error) {
          Fluttertoast.showToast(
              msg: error.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }
    }

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: ButtonTheme(
        minWidth: screenSize.width,
        height: 45.0,
        child: RaisedButton(
          elevation: 0.0,
          color: secondary,
          child: Text("Don't have an account? Sign Up",style: headingWhite18,
          ),
          onPressed: (){
            Navigator.pushNamed(context, '/signup');
          },
        ),
      ),
      body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(children: <Widget>[
                    Container(
                      height: 350.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(Config.loginBgUrl + "0"),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                    new Padding(
                        padding: EdgeInsets.fromLTRB(18.0, 150.0, 18.0, 0.0),
                        child: Container(
                            height: screenSize.height,
                            width: double.infinity,
                            child: new Column(
                              children: <Widget>[
                                new Container(
                                  //padding: EdgeInsets.only(top: 100.0),
                                    child: new Material(
                                      borderRadius: BorderRadius.circular(7.0),
                                      elevation: 5.0,
                                      child: new Container(
                                        width: MediaQuery.of(context).size.width - 20.0,
                                        height: MediaQuery.of(context).size.height *0.4,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20.0)),
                                        child: new Form(
                                            key: formKey,
                                            child: new Container(
                                              padding: EdgeInsets.all(18.0),
                                              child: new Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Login', style: heading35Black,
                                                  ),
                                                  new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      TextFormField(
                                                          keyboardType: TextInputType.phone,
                                                          controller: _usernameController,
                                                          validator: validations.validateMobile,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                              ),
                                                              prefixIcon: Icon(Icons.phone,
                                                                color: Color(getColorHexFromStr('#FEDF62')), size: 20.0,),
                                                              /*suffixIcon: IconButton(
                                                                icon: Icon(CupertinoIcons.clear_thick_circled,color: greyColor2,),
                                                                onPressed: (){
                                                                },
                                                              ),*/
                                                              contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                                              hintText: 'Phone',
                                                              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      TextFormField(
                                                          keyboardType: TextInputType.visiblePassword,
                                                          controller: _passwordController,
                                                          validator: validations.validatePassword,
                                                          obscureText: true,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                              prefixIcon: Icon(Icons.lock,
                                                                  color: Color(getColorHexFromStr('#FEDF62')), size: 20.0),
                                                              contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                              hintText: 'Password',
                                                              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  new ButtonTheme(
                                                    height: 50.0,
                                                    minWidth: MediaQuery.of(context).size.width,
                                                    child: RaisedButton.icon(
                                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                      elevation: 0.0,
                                                      color: blackColor,
                                                      icon: new Text(''),
                                                      label: new Text('LOGIN', style: headingWhite,),
                                                      onPressed: (){
                                                        _checkLogin();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                      ),
                                    )
                                ),
                                /*new Container(
                                    padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Text("Create new account? ",style: textGrey,),
                                        new InkWell(
                                          onTap: () => Navigator.pushNamed(context, '/signup'),
                                          child: new Text("Sign Up",style: textStyleActive,),
                                        ),
                                      ],
                                    )
                                ),*/
                              ],
                            )
                        )
                    ),
                  ]
                  )
                ]
            ),
          )
      ),
    );


/*
    return Scaffold(
      body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(children: <Widget>[
                    Container(
                      height: 250.0,
                      width: double.infinity,
                      color: Color(0xFFFDD148),
                    ),
                    Positioned(
                      bottom: 450.0,
                      right: 100.0,
                      child: Container(
                        height: 400.0,
                        width: 400.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200.0),
                          color: Color(0xFF0052a4),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 500.0,
                      left: 150.0,
                      child: Container(
                          height: 300.0,
                          width: 300.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(150.0),
                              color: Color(0xFFFEE16D).withOpacity(0.5))),
                    ),
                    new Padding(
                        padding: EdgeInsets.fromLTRB(32.0, 150.0, 32.0, 0.0),
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: new Column(
                              children: <Widget>[
                                new Container(
                                  //padding: EdgeInsets.only(top: 100.0),
                                    child: new Material(
                                      borderRadius: BorderRadius.circular(7.0),
                                      elevation: 5.0,
                                      child: new Container(
                                        width: MediaQuery.of(context).size.width - 20.0,
                                        height: MediaQuery.of(context).size.height *0.55,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20.0)),
                                        child: new Form(
                                            key: formKey,
                                            child: new Container(
                                              padding: EdgeInsets.all(18.0),
                                              child: new Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Login', style: heading35Black,
                                                  ),
                                                  new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      TextFormField(
                                                          keyboardType: TextInputType.phone,
                                                          controller: _usernameController,
                                                          validator: validations.validateMobile,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                              prefixIcon: Icon(Icons.phone,
                                                                  color: Color(getColorHexFromStr('#FEDF62')), size: 20.0),
                                                              contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                              hintText: 'Phone',
                                                              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      TextFormField(
                                                          keyboardType: TextInputType.visiblePassword,
                                                          controller: _passwordController,
                                                          validator: validations.validatePassword,
                                                          obscureText: true,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                              prefixIcon: Icon(Icons.lock,
                                                                  color: Color(getColorHexFromStr('#FEDF62')), size: 20.0),
                                                              contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                              hintText: 'Password',
                                                              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  new ButtonTheme(
                                                    height: 45.0,
                                                    minWidth: MediaQuery.of(context).size.width,
                                                    child: RaisedButton.icon(
                                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                                                      elevation: 0.0,
                                                      color: blackColor,
                                                      icon: new Text(''),
                                                      label: new Text('NEXT', style: headingWhite,),
                                                      onPressed: (){
                                                        _checkLogin();
                                                        },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                      ),
                                    )
                                ),
                                new Container(
                                    padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Text("Create new account? ",style: textGrey,),
                                        new InkWell(
                                          onTap: () => Navigator.pushNamed(context, '/signup'),
                                          child: new Text("Sign Up",style: textStyleActive,),
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            )
                        )
                    ),
                  ]
                  )
                ]
            ),
          )
      ),
    );

*/

  }
}
