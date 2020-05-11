import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/components/webview_util.dart';
import 'package:erdifny/components/youtube_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:http/http.dart' as http;
import 'package:erdifny/utils/urls.dart';
import 'package:erdifny/screen/imagefullscreen.dart';

class BlogView extends StatefulWidget {
  BlogView({Key key}) : super(key: key);

  @override
  _BlogViewState createState() {
    return _BlogViewState();
  }
}

class _BlogViewState extends State<BlogView> {

  var _url="http://www.google.com";
  final _key = UniqueKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var bid, btitle, bsub, bimage ;
  List  BlogDetail,BlogImageList;
  bool showProgress;
  Map data;
  int imageindex=0;


  bool _isPlayerReady = false;


  @override
  void initState() {
    super.initState();
    getSharedStore();



  }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bid = prefs.getString(Const.B_ID) ?? '';
      btitle = prefs.getString(Const.B_TITLE) ?? '';
      bsub = prefs.getString(Const.B_SUB) ?? '';
      bimage = prefs.getString(Const.B_IMAGE) ?? '';
    });
    _getBlogDetails();
  }


  _getBlogDetails() async {
    showProgress=true;
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput = '{"key": "' + Const.APPKEY +'","bid":"'+bid+ '"}';
    debugPrint("" + jsonInput);
    final response =
    await http.post(Urls.BlogView, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);
    if(response.statusCode==200){
      showProgress=false;
      if (data["success"] == true) {
        setState(() {

          BlogDetail = data["blog"];
          BlogImageList = data["blogimage"];
          debugPrint("" + BlogImageList.toString());

          if(BlogImageList.length==0 && BlogImageList!=null && BlogDetail[0]["para1"]!=""){
            setState(() {
              imageindex=1;
            });
          }

          if(BlogImageList.length>0 && BlogImageList!=null && BlogDetail[0]["para1"]!=""){
            setState(() {
              imageindex=2;
            });
          }

          if(BlogImageList.length>1 && BlogImageList!=null && BlogDetail[0]["para2"]!=""){
            setState(() {
              imageindex=3;
            });
          }



        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(fontFamily: "Calibra"),
      home: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          body:NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  titleSpacing: 0.0,
                  title: TitleSearch(),
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                      background: BannerImage(context)),
                ),
              ];
            },
            body:Container(
              decoration: BoxDecoration(
                color: ColorPalette.red,
              ),
              child: _appBody(),
            ),
          ),

        ),
      ),
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
              SizedBox(
                height: 5,
              ),
              if(BlogDetail!=null)Summary(),


              SizedBox(
                height: 80,
              ),
            ],
          ),
        ),

        MyCircularProgressBar(showProgress),
        //  TitleSearch(),
      ]),
    );
  }

  TitleSearch() {
    return Container(
      child:  SizedBox(
        height: 55,
        width: MediaQuery.of(context).size.width,
        child: Row(

          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,

          children: <Widget>[
            Container(
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                iconSize: 20,
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop(true);

                },
              ),
            ),

            Container(
              child: Text(
                "Erdifny "+AS.Blog(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.left,
              ),
            )
          ],
        ),
      ),
    );
  }

  BannerImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 350,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bgimg1.jpg'),
          fit: BoxFit.cover,
        )
        ,
      ),
      child: Stack(
        children: <Widget>[
          FadeInImage(
            image: NetworkImage(Urls.imageLocation + bimage.toString()),
            placeholder: AssetImage(Urls.DummyImageBanner),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
            height: 350,
          ),
          if(BlogDetail!=null)Positioned(
            bottom: 5,
            left: 6,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Chip(
                      backgroundColor: Colors.yellowAccent,
                      avatar: CircleAvatar(
                        backgroundColor:  Colors.yellowAccent,
                        child: Icon(Icons.remove_red_eye,color: Colors.black,size: 17,),
                      ),
                      label: Text(BlogDetail[0]["viewed"]+" Views", style: TextStyle(
                        color: ColorPalette.black,
                        fontSize: 15.0,
                      ),),
                    ),


                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Summary() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            BlogDetail[0]["title"],
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18.0,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[

              Icon(Icons.person,color: Colors.blue,size: 20,),
             Expanded(child: Text( "  "+BlogDetail[0]["author"].toString() ,maxLines: 1,
               style: TextStyle(
                 color: ColorPalette.black2,
                 fontSize: 12.0,
               ),
               textAlign: TextAlign.left,
             ) ,),

              Icon(Icons.date_range,color: Colors.blue,size: 20,),
              Text( "  "+BlogDetail[0]["n_created_on"].toString().substring(0,10) ,maxLines: 1,
                style: TextStyle(
                  color: ColorPalette.black2,
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.left,
              )
            ],),
          SizedBox(height: 10,),
          Divider(),
          SizedBox(height: 10,),
          Text(
            BlogDetail[0]["sub_title"],
            style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10,),
          Text(
            BlogDetail[0]["para1"],
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
            ),
            textAlign: TextAlign.left,
          ),

          if(BlogImageList.length>0 && BlogImageList!=null)GestureDetector(
            child: Container(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: FadeInImage(
                image: NetworkImage(Urls.imageLocation + BlogImageList[0]["nimage"]),
                placeholder: AssetImage(Urls.DummyImageBanner),
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
              ),
            ),
            onTap: (){
              Navigator.push(
                  context, MyCustomRoute(builder: (context) => ImageFullScreen(imgurl: Urls.imageLocation + BlogImageList[0]["nimage"].toString(),)));
            },
          ),
          SizedBox(height: 10,),
          Text(
            BlogDetail[0]["para2"],
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
            ),
            textAlign: TextAlign.left,
          ),
          if(BlogImageList.length>1 && BlogImageList!=null && BlogDetail[0]["para2"]!="")GestureDetector(
            child: Container(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: FadeInImage(
                image: NetworkImage(Urls.imageLocation + BlogImageList[1]["nimage"]),
                placeholder: AssetImage(Urls.DummyImageBanner),
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
              ),
            ),
            onTap: (){
              Navigator.push(
                  context, MyCustomRoute(builder: (context) => ImageFullScreen(imgurl: Urls.imageLocation + BlogImageList[1]["nimage"].toString(),)));
            },
          ),
          SizedBox(height: 10,),
          Text(
            BlogDetail[0]["para3"],
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
            ),
            textAlign: TextAlign.left,
          ),
          if(BlogImageList.length>2 && BlogImageList!=null && BlogDetail[0]["para3"]!="")GestureDetector(
            child: Container(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: FadeInImage(
                image: NetworkImage(Urls.imageLocation + BlogImageList[2]["nimage"]),
                placeholder: AssetImage(Urls.DummyImageBanner),
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
              ),
            ),
            onTap: (){
              Navigator.push(
                  context, MyCustomRoute(builder: (context) => ImageFullScreen(imgurl: Urls.imageLocation + BlogImageList[2]["nimage"].toString(),)));
            },
          ),
          SizedBox(height: 10,),
          SizedBox(height: 20,),

          if (BlogImageList != null && BlogImageList.length!=0) ProductImages(context, BlogImageList),

          if (BlogDetail[0]["youtube"] != "" && BlogDetail[0]["youtube"] != null)Container(
              height: 300,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20,),
                  Text("BLOG VIDEO",
                    style: TextStyle(
                        color: Colors.teal,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10,),
                  YoutubeUtils(youtubeurl:BlogDetail[0]["youtube"] ,),
                ],
              )


          ),

          if (BlogDetail[0]["link1"] != "" || BlogDetail[0]["link2"] != "")Container(
            height: 2500,
            child: WebviewUtils(bid: bid)
          )






        ],
      ),
    );
  }





  ProductImages(BuildContext context, List bannerList) {
    return Padding(
      padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("BLOG IMAGES",
              style: TextStyle(
                  color: Colors.teal,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20,),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: (1 / 0.7),
              controller: new ScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: List<Widget>.generate(bannerList.length, (index) {
                return CardImageList(context, index, bannerList);
              }),
            ),
          ],
        )
      ),
    );
  }
  CardImageList(BuildContext context, int i, List bannerList) {
    return Container(
        padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 10),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context, MyCustomRoute(builder: (context) => ImageFullScreen(imgurl: Urls.imageLocation + bannerList[i]["nimage"].toString(),)));
          },
          child: Material(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: FadeInImage(
                image: NetworkImage(
                    Urls.imageLocation + bannerList[i]["nimage"]),
                placeholder: AssetImage(Urls.DummyImageBanner),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 200,
                fit: BoxFit.cover,
              )
          ),
        ));
  }





}