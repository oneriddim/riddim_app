import 'package:flutter/material.dart';
import 'package:riddim_app/theme/style.dart';

class SelectService extends StatefulWidget {
  @override
  _SelectServiceState createState() => _SelectServiceState();
}

class _SelectServiceState extends State<SelectService> {
  List<Map<String, dynamic>> listService = [
    {"id": '0',"name" : 'GrabCar Plus',"price" : "\$5","estimate" : "1-3 min", "image": "assets/image/car1.png"},
    {"id": '1',"name" : 'GrabShare',"price" : "\$4","estimate" : "2-4 min", "image": "assets/image/car1.png"},
    {"id": '2',"name" : 'GrabBike',"price" : "\$2","estimate" : "1-2 min", "image": "assets/image/motorcycle.png"},
    {"id": '3',"name" : 'GrabTaxi',"price" : "\$10","estimate" : "1-3 min", "image": "assets/image/car1.png"},
    {"id": '4',"name" : 'GrabCar 7',"price" : "\$20","estimate" : "7-10 min", "image": "assets/image/car2.png"},
    ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Service",style: TextStyle(color: blackColor)),
        backgroundColor: whiteColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close,color: blackColor,),
          onPressed: (){Navigator.of(context).pop();},
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: listService.length,
          itemBuilder: (BuildContext context, index){
            return Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0,top:10.0,right: 10.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Image.asset(listService[index]['image'],height: 50.0,),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            child: Text(listService[index]['name'],style: heading18Black,),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    child: Text(listService[index]['price'],style: textBoldBlack,),
                                  ),
                                  Container(
                                    child: Text(listService[index]['estimate'],style: textGrey,),
                                  ),
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(),
              ],
            );
          }
        )
      ),
    );
  }
}
