import 'dart:convert';
import 'dart:io';

import 'package:erdifny/router/default_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/screen/blogview.dart';
import 'package:erdifny/screen/productlistscreen.dart';
import 'package:erdifny/screen/productview.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;

class BlogList extends StatefulWidget {
  BlogList({Key key}) : super(key: key);

  @override
  _BlogListState createState() {
    return _BlogListState();
  }
}

class _BlogListState extends State<BlogList> {


  int currentTabIndex = 2;
  ScrollController _scrollController = new ScrollController();
  List BlogList = new List();
  int pageCount = 1;
  Map data;
  bool showProgress=false;
  int responseStatus=0;
  int liked=0;
  var userId;

  @override
  void initState() {
    getSharedStore();
    _getDashboardItems(pageCount);
    super.initState();

  }
  _openBlogView(var id, var name, var subtitle, var image) {
    SharedStoreUtils.setValue(Const.B_TITLE, name);
    SharedStoreUtils.setValue(Const.B_SUB, subtitle);
    SharedStoreUtils.setValue(Const.B_IMAGE, image);
    SharedStoreUtils.setValue(Const.B_ID, id);

    Navigator.push(
        context, MyCustomRoute(builder: (context) => BlogView()));
  }
  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString(Const.PREF_USERID) ?? '';
    });

  }

  _getDashboardItems(int getPage) async {

    showProgress=true;
    setState(() {

      responseStatus=0;
    });
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput =
        '{"key": "' + Const.APPKEY +'","page":"' + getPage.toString() + '"}';
    debugPrint("URL--" + jsonInput);
    final response =
    await http.post(Urls.BlogList,headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);
    List tempList = new List();
    for (int i = 0; i < data["blog"].length; i++) {
      tempList.add(data["blog"][i]);
    }

    if (data["success"] == true) {
      setState(() {
        showProgress=false;
        responseStatus=200;
        BlogList.addAll(tempList);
      });
    }

    //   debugPrint("City--"+CityList.toString());
  }

  _addLike(String bid) async {
    showProgress=true;
    Map<String, String> headers = {"Content-type": "application/json"};
    String jsonInput = '{"key": "' + Const.APPKEY +'","bid":"'+bid+'","uid":"'+userId+ '"}';
    debugPrint("" + jsonInput);
    final response =
    await http.post(Urls.AddLike, headers: headers, body: jsonInput);
    data = json.decode(response.body);
    if(response.statusCode==200){
      showProgress=false;
      if (data["success"] == true) {
        if(data["action"]=="deleted"){
          setState(() {

            liked=0;
          });
        }else{
          setState(() {

            liked=1;
          });
        }

      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(fontFamily: "Calibra"),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,

        body: Container(
          decoration: BoxDecoration(
            color: ColorPalette.white,
          ),
          child: _appBody(),
        ),
      )
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
              SizedBox(height: 60.0),
              if (BlogList.length==0 ) ShowImageEmpty(),
              if(BlogList.length!=0)PackageListing(),

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
                      "Erdifny "+AS.Blog(),
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
  PackageListing() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 50),
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        //+1 for progressbar
        itemCount: BlogList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(

            child: GestureDetector(
              onTap: () {
                _openBlogView(
                    BlogList[index]["n_id"],
                    BlogList[index]["title"],
                    BlogList[index]["sub_title"],
                    BlogList[index]["image"]);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.asset("assets/images/logored.jpg",width: 40,height: 40,)),
                      SizedBox(width: 10,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text( " Erdifny Management" ,maxLines: 1,
                            style: TextStyle(
                              color: ColorPalette.red,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 2,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[

                            Icon(Icons.person,color: ColorPalette.black2,size: 17,),
                            SizedBox(width: 5,),
                            Text( BlogList[index]["author"].toString() ,maxLines: 1,
                              style: TextStyle(
                                color: ColorPalette.black2,
                                fontSize: 12.0,
                              ),
                              textAlign: TextAlign.left,
                            )
                          ],)

                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: FadeInImage(
                        image: NetworkImage(
                            Urls.imageLocation + BlogList[index]["image"]),
                        placeholder: AssetImage(Urls.DummyImageBanner),
                        width: MediaQuery.of(context).size.width  ,
                        fit: BoxFit.cover,
                      )),
                  SizedBox(height: 10.0),
                  Text( BlogList[index]["title"] ,
                    style: TextStyle(
                      color: ColorPalette.blacklight,
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.left,
                  ),

                  SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[

                      Icon(Icons.remove_red_eye,color: Colors.blue,size: 20,),
                      SizedBox(width: 5,),
                      Expanded(
                        child: Text(" "+ BlogList[index]["viewed"]+ " Views" ,maxLines: 1,
                          style: TextStyle(
                            color: ColorPalette.black2,
                            fontSize: 15.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      Icon(Icons.date_range,color: Colors.blue,size: 20,),
                      Text( "  "+BlogList[index]["n_created_on"].toString().substring(0,10) ,maxLines: 1,
                        style: TextStyle(
                          color: ColorPalette.blacklight,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],),
                  Divider(),
                  SizedBox(height: 15.0),

                ],
              ),
            ),
          );
        },
        controller: _scrollController,
      ),
    );
  }

}