import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/screen/dashboard.dart';
import 'package:erdifny/screen/productlistscreen.dart';
import 'package:erdifny/screen/productview.dart';
import 'package:erdifny/screen/userscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;

import 'bookingscreen.dart';


class LikeListScreen extends StatefulWidget {
  LikeListScreen({Key key}) : super(key: key);

  @override
  _LikeListScreenState createState() {
    return _LikeListScreenState();
  }
}

class _LikeListScreenState extends State<LikeListScreen> {

  int currentTabIndex = 2;
  ScrollController _scrollController = new ScrollController();
  List PackageList = new List();
  int pageCount = 1;
  Map data;
  bool showProgress=false;
  var userId;
  int responseStatus=0;

  @override
  void initState() {
    super.initState();
    getSharedStore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          pageCount = pageCount + 1;
        });
        _getDashboardItems(pageCount);
      }
    });
  }
  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString(Const.PREF_USERID) ?? '';
    });
    _getDashboardItems(pageCount);
  }

  _getDashboardItems(int getPage) async {
   // debugPrint("userid-"+ userId);
    showProgress=true;
    setState(() {

      responseStatus=0;
    });
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput =
        '{"key": "' + Const.APPKEY +'","uid":"'+ userId.toString() +'","page":"' + getPage.toString() + '"}';
    debugPrint("URL--" + jsonInput);
    final response =
    await http.post(Urls.LikeList, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);
    List tempList = new List();
    for (int i = 0; i < data["packlist"].length; i++) {
      tempList.add(data["packlist"][i]);
    }

    if (data["success"] == true) {
      setState(() {
        showProgress=false;
        responseStatus=200;
        PackageList.addAll(tempList);
      });
    }

    //   debugPrint("City--"+CityList.toString());
  }

  _openProductView(var id, var name, var subtitle, var image, var vendor) {
    SharedStoreUtils.setValue(Const.PREF_PID, id);
    SharedStoreUtils.setValue(Const.PREF_PNAME, name);
    SharedStoreUtils.setValue(Const.PREF_PSUB, subtitle);
    SharedStoreUtils.setValue(Const.PREF_PIMAGE, image);
    SharedStoreUtils.setValue(Const.PREF_PVENDOR, vendor);

    Navigator.push(
        context, MyCustomRoute(builder: (context) => ProductView()));
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: false,

      body: Container(
        decoration: BoxDecoration(
          color: ColorPalette.white,
        ),
        child: _appBody(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );

  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(height: 80.0),
              if (PackageList.length==0 ) ShowImageEmpty(),
              if(PackageList.length!=0)PackageListing(),

              SizedBox(height: 110.0),
            ],
          ),
        ),
        TitleSearch(),
        MyCircularProgressBar(showProgress),
      ]),
    );
  }

  TitleSearch() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Padding(
          padding: EdgeInsets.fromLTRB(5, 25, 5, 5),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10,),
              Row(

                children: <Widget>[

                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(
                      AS.MyFavourite(),
                      style: TextStyle(color: ColorPalette.red, fontSize: 22.0,fontWeight: FontWeight.bold),

                      textAlign: TextAlign.left,
                    ),
                  ),

                ],
              ),
              SizedBox(height: 3,),
            ],
          )
      ),
    );
  }

  PackageListing() {
    return Container(
      height: MediaQuery.of(context).size.height-100,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        //+1 for progressbar
        itemCount: PackageList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(

            child: GestureDetector(
              onTap: () {
                _openProductView(
                    PackageList[index]["p_id"],
                    PackageList[index]["p_name"],
                    PackageList[index]["p_sub"],
                    PackageList[index]["p_image"],
                    PackageList[index]["vendor_id"]);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: FadeInImage(
                        image: NetworkImage(
                            Urls.imageLocation + PackageList[index]["p_image"]),
                        placeholder: AssetImage(Urls.DummyImageBanner),
                        width: MediaQuery.of(context).size.width  ,
                        height: 200,
                        fit: BoxFit.cover,
                      )),
                  SizedBox(height: 10.0),
                  Row(
                    children: <Widget>[
                      Text(PackageList[index]["city_name"].toString().toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,

                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        "" + PackageList[index]["p_name"],
                        maxLines: 1,
                        style: TextStyle(
                          color: ColorPalette.black2,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),

                  SizedBox(height: 5.0),
                  RatingStars(PackageList[index]["ratings"],
                      PackageList[index]["count"]),
                  SizedBox(height: 3.0),
                  Text(
                    "" +
                        PackageList[index]["adultprice"].toString() +" "+Const.CURRENCY+
                        " ( " +
                        PackageList[index]["days"].toString() +
                        " )",
                    maxLines: 1,
                    style: TextStyle(
                      color: ColorPalette.black2,
                      fontSize: 13.0,
                    ),
                    textAlign: TextAlign.left,
                  ),


                  SizedBox(height: 30.0),
                ],
              ),
            ),
          );
        },
        controller: _scrollController,
      ),
    );
  }

  RatingStars(var ratings, var count) {
    switch (ratings) {
      case "0":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            SizedBox(width: 5.0),
            Text(
              "" + count + " "+AS.Reviews(),
              maxLines: 1,
              style: TextStyle(
                color: ColorPalette.black1,
                fontSize: 12.0,
              ),
              textAlign: TextAlign.left,
            )
          ],
        );
        break;

      case "1":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            SizedBox(width: 5.0),
            Text(
              "" + count + " "+AS.Reviews(),
              maxLines: 1,
              style: TextStyle(
                color: ColorPalette.black1,
                fontSize: 12.0,
              ),
              textAlign: TextAlign.left,
            )
          ],
        );
        break;

      case "2":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            SizedBox(width: 5.0),
            Text(
              "" + count + " "+AS.Reviews(),
              maxLines: 1,
              style: TextStyle(
                color: ColorPalette.black1,
                fontSize: 12.0,
              ),
              textAlign: TextAlign.left,
            )
          ],
        );
        break;

      case "3":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            SizedBox(width: 5.0),
            Text(
              "" + count + " "+AS.Reviews(),
              maxLines: 1,
              style: TextStyle(
                color: ColorPalette.black1,
                fontSize: 12.0,
              ),
              textAlign: TextAlign.left,
            )
          ],
        );
        break;

      case "4":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            SizedBox(width: 5.0),
            Text(
              "" + count + " "+AS.Reviews(),
              maxLines: 1,
              style: TextStyle(
                color: ColorPalette.black1,
                fontSize: 12.0,
              ),
              textAlign: TextAlign.left,
            )
          ],
        );
        break;

      case "5":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            SizedBox(width: 4.0),
            Text(
              "" + count + " "+AS.Reviews(),
              maxLines: 1,
              style: TextStyle(
                color: ColorPalette.black1,
                fontSize: 12.0,
              ),
              textAlign: TextAlign.left,
            )
          ],
        );
        break;
    };
  }



  ShowImageEmpty() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child:  Column(
        children: <Widget>[
          SizedBox(height: 20,),
          Image.asset(
            "assets/images/nolikes.jpg",
            width: MediaQuery.of(context).size.width,
            height: 250,
          ),
          SizedBox(height: 20,),
          Text(AS.NoLikeList(),
            maxLines: 1,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,

            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20,),
          OutlineButton(
            child: Text(AS.Explore(),
                style: TextStyle(
                  color: ColorPalette.TextColorRegular,
                  fontSize: 12.0,
                )),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  new MyCustomRoute(
                      builder: (context) => new ProductListingScreen()));
            },
            borderSide: BorderSide(
              color: ColorPalette.TextColorRegular,
              style: BorderStyle.solid,
              width: 0.8,
            ),
          ),



        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: ColorPalette.red,
      selectedItemColor: ColorPalette.white,
      unselectedItemColor: Colors.grey[200],
      unselectedIconTheme: IconThemeData(color: Colors.grey[300]),
      selectedIconTheme: IconThemeData(color: Colors.white,size: 27),
      onTap: _onBottomItemClicked,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.search), title: Text(AS.Explore())),
        BottomNavigationBarItem(
            icon: Icon(Icons.filter_hdr), title: Text(AS.Booking(),)),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), title: Text(AS.Saved())),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), title: Text(AS.You())),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: currentTabIndex,
    );
  }

  _onBottomItemClicked(int index) {
    setState(() {
      switch(index){
        case 0:
          Navigator.of(context).pop(true);
          break;
        case 1:
          Navigator.pushReplacement(
              context, MyCustomRoute(builder: (context) => BookingScreen()));
          break;

        case 3:
          Navigator.pushReplacement(
              context, MyCustomRoute(builder: (context) => UserScreen()));
          break;
      }
    });
  }

  Future<bool> _onBackPressed() {
    Navigator.canPop(context);
  }
}