import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app/Repository/konnectRepository.dart';
import 'package:riddim_app/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/theme/style.dart';
import 'package:riddim_app/Screen/Menu/Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import 'detail.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:cached_network_image/cached_network_image.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final userRepository = KonnectRepository();
  final String screenName = "REVIEWS";
  DateTime selectedDate = DateTime.now();
  List<dynamic> _listRequest = List<dynamic>();
  String selectedMonth = '';
  User _currentUser;
  String _currentTicketId = "";

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

    _getCompletedTickets();
  }

  void _getCompletedTickets() async {
    if (_currentUser != null) {
      Fluttertoast.showToast(
          msg: "Getting Reviews",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );

      final results = await userRepository.getReviews(
          token: _currentUser.userid
      );
      setState(() {
        _listRequest = results;
      });
    }
  }

  navigateToDetail(String ticket) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString("ticket", ticket);
    //Navigator.of(context).push(MaterialPageRoute(builder: (context) => HistoryDetail()));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      drawer: _currentUser != null? new MenuScreens(activeScreenName: screenName, user: _currentUser): new MenuScreensDefault(activeScreenName: screenName),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                    itemCount: _listRequest.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            print('$index');
                            navigateToDetail(_listRequest[index]["id"]);
                          },
                          child: reviewItem(index)
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget reviewItem(int index) {
    return Card(
        margin: EdgeInsets.all(10.0),
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: CachedNetworkImage(
                          imageUrl: Config.userImageUrl + _listRequest[index]['avatar'],
                          fit: BoxFit.cover,
                          width: 40.0,
                          height: 40.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_listRequest[index]['name'],style: textBoldBlack,),
                          Text(_listRequest[index]['date'], style: textGrey,),
                          Container(
                            child: Row(
                              children: <Widget>[
                                RatingBar(
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  ignoreGestures: true,
                                  initialRating:  double.parse(_listRequest[index]['rating']),
                                  itemSize: 15.0,
                                  itemCount: 5,
                                  glowColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    /*Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text("\$" + _listRequest[index]['price'],style: textBoldBlack,),
                          Text(_listRequest[index]['distance'] + " Km",style: textGrey,),
                        ],
                      ),
                    ),*/
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_listRequest[index]['review'],style: textStyle,),
                        ],
                      ),
                    ),

                  ],
                )
              ),
            ],
          ),
        ),
      );
  }
}
