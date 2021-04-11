import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riddim_app/Components/validations.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:riddim_app/Components/inputDropdown.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

const double _kPickerSheetHeight = 216.0;

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool autovalidate = false;
  Validations validations = new Validations();
  List<Map<String, dynamic>> listGender = [{"id": '0',"name" : 'Male',},{"id": '1',"name" : 'Female',}];
  String selectedGender;
  String lastSelectedValue;
  DateTime date = DateTime.now();
  var _image;
  User _currentUser;

  String name;
  String contact;
  String email;
  String address;

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
      selectedGender = _currentUser.gender;
      name = _currentUser.fullname;
      contact = _currentUser.username;
      email = _currentUser.email;
      address = _currentUser.address;
      if (_currentUser.dob != "") {
        date = DateTime.parse(_currentUser.dob + " 00:00:00");
      }
    });
  }

  Future getImageLibrary() async {
    var gallery = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth: 700);
    setState(() {
      _image = gallery;
      print(_image);
    });
  }

  Future cameraImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 700);
    setState(() {
      _image = image;
      print(_image);
    });
  }


  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      if (value != null) {
        setState(() { lastSelectedValue = value; });
      }
    });
  }

  selectCamera () {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
          title: const Text('Select Camera'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.pop(context, 'Camera');
                cameraImage();
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Photo Library'),
              onPressed: () {
                Navigator.pop(context, 'Photo Library');
                getImageLibrary();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          )
      ),
    );
  }

  _submit() async {
    final FormState form = formKey.currentState;
    if (!form.validate()) {
      autovalidate = true; // Start validating on every change.
    } else {
      form.save();

      Fluttertoast.showToast(
          msg: "Please wait..",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );

      final success = await userRepository.saveProfile(
        token: _currentUser.userid,
        name: name,
        contact: contact,
        email: email,
        gender: selectedGender,
        dob: DateFormat("yyyy-MM-dd").format(date),
        address: address,
        image: _image
      );

      if(success) {
        DefaultCacheManager manager = new DefaultCacheManager();
        manager.emptyCache();

        Fluttertoast.showToast(
            msg: "Saved",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );

        Navigator.of(context).pushReplacementNamed('/profile');
        Navigator.popAndPushNamed(context, '/profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        title: Text(
          'My Profile',
          style: TextStyle(color: blackColor),
        ),
      ),
      bottomNavigationBar: ButtonTheme(
        minWidth: screenSize.width,
        height: 45.0,
        child: RaisedButton(
          elevation: 0.0,
          color: primaryColor,
          child: Text('SAVE',style: headingWhite,
          ),
          onPressed: (){
            _submit();
          },
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Form(
                key: formKey,
                child: Container(
                  color: Color(0xffeeeeee),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: whiteColor,
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(bottom: 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(50.0),
                              child: new ClipRRect(
                                  borderRadius: new BorderRadius.circular(100.0),
                                  child:_image == null
                                      ? new GestureDetector(
                                      onTap: (){selectCamera();},
                                      child: new Container(
                                          height: 80.0,
                                          width: 80.0,
                                          color: primaryColor,
                                          child: _currentUser == null ?  new Image.network(Config.userImageUrl + "-1" ,fit: BoxFit.cover, height: 80.0,width: 80.0,) :  new Image.network(Config.userImageUrl + _currentUser.userid,fit: BoxFit.cover, height: 80.0,width: 80.0,)
                                      )
                                  ): new GestureDetector(
                                      onTap: () {selectCamera();},
                                      child: new Container(
                                        height: 80.0,
                                        width: 80.0,
                                        child: Image.file(_image,fit: BoxFit.cover, height: 800.0,width: 80.0,),
                                      )
                                  )
                              ),
                            ),
                            Expanded(
                              child: Container(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                  "Name",
                                  style: textStyle,
                                ),
                                  TextFormField(
                                    style: textStyle,
                                    validator: validations.validateName,
                                    decoration: InputDecoration(
                                        fillColor: whiteColor,
                                        labelStyle: textStyle,
                                        hintStyle: TextStyle(color: Colors.white),
                                        counterStyle: textStyle,
                                        hintText: "Name",
                                        border: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white))),
                                    controller:
                                        new TextEditingController.fromValue(
                                      new TextEditingValue(
                                        text: _currentUser == null ? "" :  _currentUser.fullname,
                                        selection: new TextSelection.collapsed(
                                            offset: 11),
                                      ),
                                    ),
                                    onChanged: (String _firstName) {
                                      name = _firstName;

                                    },
                                  ),
                                  /*TextField(
                                    style: textStyle,
                                    decoration: InputDecoration(
                                        fillColor: whiteColor,
                                        labelStyle: textStyle,
                                        hintStyle: TextStyle(color: Colors.white),
                                        counterStyle: textStyle,
                                        hintText: "Last Name",
                                        border: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white))),
                                    controller:
                                        new TextEditingController.fromValue(
                                      new TextEditingValue(
                                        text: "Last Name",
                                        selection: new TextSelection.collapsed(
                                            offset: 11),
                                      ),
                                    ),
                                    onChanged: (String _lastName) {

                                    },
                                  ),*/
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                      Container(
                        color: whiteColor,
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(top: 10.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Phone Number",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      style: textStyle,
                                      keyboardType: TextInputType.phone,
                                      validator: validations.validateMobile,
                                      decoration: InputDecoration(
                                          fillColor: whiteColor,
                                          labelStyle: textStyle,
                                          hintStyle: TextStyle(color: Colors.white),
                                          counterStyle: textStyle,
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))
                                      ),
                                      controller: new TextEditingController.fromValue(
                                        new TextEditingValue(
                                          text: _currentUser == null ? "" : _currentUser.contact,
                                          selection: new TextSelection.collapsed(
                                              offset: 11),
                                        ),
                                      ),
                                      onChanged: (String _phone) {
                                        contact = _phone;

                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Email",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      style: textStyle,
                                      decoration: InputDecoration(
                                          fillColor: whiteColor,
                                          labelStyle: textStyle,
                                          hintStyle:
                                          TextStyle(color: Colors.white),
                                          counterStyle: textStyle,
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))
                                      ),
                                      controller: new TextEditingController.fromValue(
                                        new TextEditingValue(
                                          text: _currentUser == null ? "" : _currentUser.email,
                                          selection: new TextSelection.collapsed(
                                              offset: 11),
                                        ),
                                      ),
                                      onChanged: (String _email) {
                                        email = _email;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Gender",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: new DropdownButtonHideUnderline(
                                        child: Container(
                                         // padding: EdgeInsets.only(bottom: 12.0),
                                          child: new InputDecorator(
                                            decoration: const InputDecoration(
                                            ),
                                            isEmpty: selectedGender == null,
                                            child: new DropdownButton<String>(
                                              hint: new Text("Gender",style: textStyle,),
                                              value: selectedGender,
                                              isDense: true,
                                              onChanged: (String newValue) {
                                                setState(() {
                                                  selectedGender = newValue;
                                                  print(selectedGender);
                                                });
                                              },
                                              items: listGender.map((value) {
                                                return new DropdownMenuItem<String>(
                                                  value: value['id'],
                                                  child: new Text(value['name'],style: textStyle,),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Birthday",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child:  GestureDetector(
                                        onTap: () {
                                          showCupertinoModalPopup<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return _buildBottomPicker(
                                                CupertinoDatePicker(
                                                  mode: CupertinoDatePickerMode.date,
                                                  initialDateTime: date,
                                                  onDateTimeChanged: (DateTime newDateTime) {
                                                    setState(() {
                                                      date = newDateTime;
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: new InputDropdown(
                                          valueText: DateFormat.yMMMMd().format(date),
                                          valueStyle: TextStyle(color: blackColor),
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        "Address",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      style: textStyle,
                                      maxLines: 2,
                                      decoration: InputDecoration(
                                          fillColor: whiteColor,
                                          labelStyle: textStyle,
                                          hintStyle:
                                          TextStyle(color: Colors.white),
                                          counterStyle: textStyle,
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))
                                      ),
                                      controller: new TextEditingController.fromValue(
                                        new TextEditingValue(
                                          text: _currentUser == null ? "" : _currentUser.address,
                                          selection: new TextSelection.collapsed(
                                              offset: 11),
                                        ),
                                      ),
                                      onChanged: (String _address) {
                                        address = _address;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            /*Container(
                              padding: EdgeInsets.only(top: 20.0),
                              child: new ButtonTheme(
                                height: 45.0,
                                minWidth: MediaQuery.of(context).size.width-50,
                                child: RaisedButton.icon(
                                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                                  elevation: 0.0,
                                  color: primaryColor,
                                  icon: new Text(''),
                                  label: new Text('SAVE', style: headingBlack,),
                                  onPressed: (){
                                    _submit();
                                  },
                                ),
                              ),
                            )*/
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
        ),
      ),
    );
  }
}
