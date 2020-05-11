import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:erdifny/components/url_open.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/screen/bloglist.dart';
import 'package:erdifny/screen/bookingscreen.dart';
import 'package:erdifny/screen/likelistscreen.dart';
import 'package:erdifny/screen/productlistscreen.dart';
import 'package:erdifny/screen/productview.dart';
import 'package:erdifny/screen/userscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:http/http.dart' as http;
import 'package:erdifny/utils/urls.dart';
//import 'package:english_words/english_words.dart' as english_words;
import 'package:url_launcher/url_launcher.dart';

import 'blogview.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {

  _MySearchDelegate _delegate;


  int currentTabIndex = 0;
  bool showProgress;
  Map data;
  List PackageList, CityList, BannerList,BlogAllList;
  List<String> CityName = [];
  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> AutoCompletekey =
      new GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  GlobalKey<AutoCompleteTextFieldState<String>> AutoCompletekey2 =
  new GlobalKey();

  ScrollController _controller;

  bool showTitle=false;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
    showProgress = false;
    _getDashboardItems();


  }

  _scrollListener() {

    debugPrint("eeee-"+_controller.offset.toString());
    if(_controller.offset>333.70777774743254){
      setState(() {
        showTitle=true;
      });
    }else{
      setState(() {
        showTitle=false;
      });
    }


  }

  _openBlogView(var id, var name, var subtitle, var image) {
    SharedStoreUtils.setValue(Const.B_TITLE, name);
    SharedStoreUtils.setValue(Const.B_SUB, subtitle);
    SharedStoreUtils.setValue(Const.B_IMAGE, image);
    SharedStoreUtils.setValue(Const.B_ID, id);

    Navigator.push(
        context, MyCustomRoute(builder: (context) => BlogView()));
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getDashboardItems() async {
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput = '{"key": "' + Const.APPKEY + '"}';
    // debugPrint("" + jsonInput);
    final response =
        await http.post(Urls.Dashboard, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);

    if (data["success"] == true) {
      setState(() {
        PackageList = data["packlist"];
        CityList = data["citylist"];
        BannerList = data["bannerlist"];
        BlogAllList = data["blog"];
      });

      for (int i = 0; i < CityList.length; i++) {
        setState(() {
          String cityNameTemp=CityList[i]["city_name"].toString();
          CityName.add(cityNameTemp.toLowerCase());
        });
      }
      _delegate = _MySearchDelegate(CityName);



    }
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
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: MaterialApp(
        theme: ThemeData(fontFamily: "Calibra"),
        home: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomPadding: false,
            key: _scaffoldKey,
            body: Container(
              decoration: BoxDecoration(
                color: ColorPalette.white,
              ),
              child: _appBody(),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          ),
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
          controller: _controller,

          child: Column(
            children: <Widget>[
              if (BannerList != null) TopBannerSlide(context),
              SizedBox(height: 20.0),
              AppInformationText(context),
              SizedBox(height: 30.0),
              LatestTitle(),
              SizedBox(height: 20.0),
              if (PackageList != null) DashPackList(context, PackageList),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 55,
                padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: OutlineButton(
                  child: Text(AS.ViewAllPack(),
                      style: TextStyle(
                        color: ColorPalette.TextColorRegular,
                        fontSize: 12.0,
                      )),
                  onPressed: () {       Navigator.push(
                      context,
                      MyCustomRoute(
                          builder: (context) => ProductListingScreen(
                            GetCity: "",
                          )));},
                  borderSide: BorderSide(
                    color: ColorPalette.TextColorRegular,
                    style: BorderStyle.solid,
                    width: 0.8,
                  ),
                ),
              ),

              SizedBox(height: 15.0),
              ExploreMessage(context),

              SizedBox(height: 30.0),
              TitlewithUnderline(AS.OurBlog(),50.0),
              SizedBox(height: 10.0),
              if (BlogAllList != null) BlogSlide(context, BlogAllList),
              SizedBox(height: 35.0),
              TitlewithUnderline(AS.TopAttraction(),80.0),
              SizedBox(height: 25.0),
              if (PackageList != null) PackageBannerSlide(context, PackageList),
              SizedBox(height: 10.0),
           //   TitleBookingMessage(context),
              SizedBox(height: 30.0),
              TitleCity(),
              SizedBox(height: 10.0),
              if (CityList != null) CityImageList(context, CityList),

              SizedBox(height: 30.0),

            ],
          ),
        ),


        if(showTitle)TitleSearch(),
      ]),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
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
      switch (index) {
        case 1:
          Navigator.push(context,
              MyCustomRoute(builder: (context) => BookingScreen()));
          break;
        case 2:
          Navigator.push(context,
              MyCustomRoute(builder: (context) => LikeListScreen()));
          break;
        case 3:
          Navigator.push(
              context, MyCustomRoute(builder: (context) => UserScreen()));
          break;
      }
    });
  }

  TitleSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10 , 10, 10),
        child: Material(
            elevation: 5.0,
            color: ColorPalette.white,
            child:GestureDetector(
              child:  Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(width: 10,),
                      Icon(Icons.search,color: ColorPalette.red,size: 25,),
                      SizedBox(width: 10,),
                      Expanded(child: Text(AS.whereareyougoing(),style: TextStyle(color: ColorPalette.titleSearchbar,fontSize: 17),),),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.whatsapp,color: Colors.black.withOpacity(0.5),),
                        onPressed: () async {

                          UrlOpenUtils.whatsapp(_scaffoldKey);

                        },
                      ),

                    ],
                  )),
              onTap: ()async {
                final String selected = await showSearch<String>(
                  context: context,
                  delegate: _delegate,
                );
                if (selected != null) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You have selected the word: $selected'),
                    ),
                  );
                }
              },
            )),
      ),
    );
  }


  TopBannerSlide(BuildContext context) {
    double ContainerHeight=300.0;
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: ContainerHeight,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: ContainerHeight-35,
          child: CarouselSlider.builder(
            itemCount: BannerList.length,
            height: ContainerHeight,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 10),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: Duration(seconds: 10),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int itemIndex) => Container(
              width: MediaQuery.of(context).size.width,
              height: ContainerHeight,
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                      child: FadeInImage.memoryNetwork(
                        image: Urls.imageLocation +
                            BannerList[itemIndex]["ban_image"],
                        placeholder: kTransparentImage,
                        width: MediaQuery.of(context).size.width,
                        height: ContainerHeight,
                        fit: BoxFit.cover,
                      )
                  ),

                  Positioned(
                      bottom: 35,
                      left: 10,
                      right: 150,
                      child: Text(
                        BannerList[itemIndex]["ban_text"].toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            height: 1.2,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      )
                  ),

                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child:Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 0 , 10, 10),
              child: Material(
                  elevation: 5.0,
                  color: ColorPalette.white,
                  child: GestureDetector(
                    child:  Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(10, 5, 20, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(width: 10,),
                            Icon(Icons.search,color: ColorPalette.red,size: 25,),
                            SizedBox(width: 10,),
                            Expanded(child: Text(AS.whereareyougoing(),style: TextStyle(color: ColorPalette.titleSearchbar,fontSize: 17),),),
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.whatsapp,color: Colors.black.withOpacity(0.5),),
                              onPressed: () async {
                                UrlOpenUtils.whatsapp(_scaffoldKey);
                              },
                            ),

                          ],
                        )),
                    onTap: ()async {
                      final String selected = await showSearch<String>(
                        context: context,
                        delegate: _delegate,
                      );
                      if (selected != null) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You have selected the word: $selected'),
                          ),
                        );
                      }
                    },
                  )),
            ),
          ),
        )
      ],
    );
  }


  AppInformationText(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 25, 20, 20),
      decoration: BoxDecoration(
        color: ColorPalette.blueSkyLighter,
      ),
      child:   Column(
        children: <Widget>[
          Text(
            AS.Dashbannertitle(),
            style: TextStyle(color: Colors.blueGrey[800], fontSize: 15.0,fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            AS.DashbannerDetail(),
            style: TextStyle(color: Colors.black, fontSize: 15.0),
            textAlign: TextAlign.center,
          ),
        ],
      )
    );
  }

  TitlewithUnderline(var value,var barsize){
    return   Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Text(
            value,
            style: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 5.0),
        Center(
          child: Container(
            width: barsize,
            height: 2,
            color: ColorPalette.red,
          ),
        ),
      ],
    );
  }

  PackageBannerSlide(BuildContext context, List packageList) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.width,
            child: PageView.builder(
              itemCount: 5,
              physics: BouncingScrollPhysics(),
              controller: PageController(viewportFraction: 0.8, initialPage: 1),
              itemBuilder: (_, i) {
                return CardPackageBannerSlides(context, i, packageList);
              },
            ),
          ),
        )
      ],
    );
  }

  CardPackageBannerSlides(BuildContext context, int i, List packageList) {
    return Container(
        padding:
            EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MyCustomRoute(
                    builder: (context) => ProductListingScreen()));
          },
          child: Material(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: FadeInImage(
                      image: NetworkImage(
                          Urls.imageLocation + packageList[i]["p_image"]),
                      placeholder: AssetImage(Urls.DummyImageBanner),

                      fit: BoxFit.cover,
                    )),

                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "" + packageList[i]["p_name"],
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "" + packageList[i]["p_sub"],
                            maxLines: 2,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  BlogSlide(BuildContext context, List blogalllist) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.width,
            child: PageView.builder(
              itemCount: 5,
              physics: BouncingScrollPhysics(),
              controller: PageController(viewportFraction: 0.8, initialPage: 1),
              itemBuilder: (_, i) {
                return CardBlogSlides(context, i, blogalllist);
              },
            ),
          ),
        ),
      ],
    );
  }

  CardBlogSlides(BuildContext context, int i, List getBlogList) {
    if(getBlogList.length==(i+1)){
      return Container(
          padding:
          EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
          child: GestureDetector(
            onTap: () {

              Navigator.push(
                  context, MyCustomRoute(builder: (context) => BlogList()));
            },
            child: Material(
              elevation: 1.0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Expanded(
                      child: Container(
                        height: 200,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: FadeInImage(
                                  image: NetworkImage(
                                      Urls.imageLocation + getBlogList[i]["image"]),
                                  placeholder: AssetImage(Urls.DummyImageBanner),
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )),
                            Container(
                              alignment: Alignment.center,
                              color: ColorPalette.black_opacity_overy,
                              width: 200,
                              child: Text("View All blog",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                            ),

                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            getBlogList[i]["title"],
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15.0,),
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
                                child: Text(" "+ getBlogList[i]["viewed"]+ " Views" ,maxLines: 1,
                                  style: TextStyle(
                                    color: ColorPalette.black2,
                                    fontSize: 15.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),

                              Icon(Icons.date_range,color: Colors.blue,size: 20,),
                              Text( "  "+getBlogList[i]["n_created_on"].toString().substring(0,10) ,maxLines: 1,
                                style: TextStyle(
                                  color: ColorPalette.blacklight,
                                  fontSize: 12.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],),
                        ],
                      ),
                    )

                  ],

                ),
              ),
            ),
          ));
    }else{
      return Container(
          padding:
          EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
          child: GestureDetector(
            onTap: () {

              _openBlogView(
                  getBlogList[i]["n_id"],
                  getBlogList[i]["title"],
                  getBlogList[i]["sub_title"],
                  getBlogList[i]["image"]);
            },
            child: Material(
              elevation: 1.0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: FadeInImage(
                            image: NetworkImage(
                                Urls.imageLocation + getBlogList[i]["image"]),
                            placeholder: AssetImage(Urls.DummyImageBanner),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 200,
                            fit: BoxFit.cover,
                          )),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "" + getBlogList[i]["title"],
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15.0,),
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
                                child: Text(" "+ getBlogList[i]["viewed"]+ " Views" ,maxLines: 1,
                                  style: TextStyle(
                                    color: ColorPalette.black2,
                                    fontSize: 15.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),

                              Icon(Icons.date_range,color: Colors.blue,size: 20,),
                              Text( "  "+getBlogList[i]["n_created_on"].toString().substring(0,10) ,maxLines: 1,
                                style: TextStyle(
                                  color: ColorPalette.blacklight,
                                  fontSize: 12.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],),
                        ],
                      ),
                    )

                  ],

                ),
              ),
            ),
          ));
    }

  }

  ExploreMessage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 2, 0, 5),
      decoration: BoxDecoration(
        color: ColorPalette.blueSkyLighter,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20.0),
          Center(
            child: Image.asset(
              "assets/images/marker.png",
              width: 40,
              height: 40,
            ),
          ),
          SizedBox(height: 8.0),
          Center(
            child: Text(
              AS.Whatdoyouwanttosee(),
              style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 10.0),
          Center(
            child: Text(
              AS.DiscoverAmazing(),
              style: TextStyle(color: Colors.black, fontSize: 15.0),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.0),
          Center(
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: BorderSide(color: ColorPalette.blueSkyLight, width: 1)),
              onPressed: () {
                Navigator.push(
                    context,
                    MyCustomRoute(
                        builder: (context) => ProductListingScreen(
                              GetCity: "",
                            )));
              },
              color: ColorPalette.white,
              textColor: ColorPalette.blacklight,
              child:
                  Text(AS.ExploreMore().toUpperCase(), style: TextStyle(fontSize: 14,color: Colors.blueGrey[800])),
            ),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  TitleCity() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 2, 20, 5),
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              AS.TopDistination(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 5.0),
          Center(
            child: Container(
              width: 60,
              height: 2,
              color: ColorPalette.red,
            ),
          ),
        ],
      ),
    );
  }

  CityImageList(BuildContext context, List cityList) {
    return Padding(
      padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
      child: Container(
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: (1 / 0.9),
          controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: List<Widget>.generate(cityList.length, (index) {
            return CardCityImageList(context, index, cityList);
          }),
        ),
      ),
    );
  }

  CardCityImageList(BuildContext context, int i, List cityList) {
    return Container(
        padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MyCustomRoute(
                    builder: (context) => ProductListingScreen(
                          GetCity: cityList[i]["city_name"],
                        )));
          },
          child: Material(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: FadeInImage(
                      image: NetworkImage(
                          Urls.imageLocation + cityList[i]["city_image"]),
                      placeholder: AssetImage(Urls.DummyImageBanner),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 300,
                      fit: BoxFit.cover,
                    )),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                        ColorPalette.black_opacity2,
                        ColorPalette.black_hide
                      ]))),
                ),
                Positioned(
                  top: 7,
                  left: 5,
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width * 0.5) / 2,
                    child: Text(
                      "" + cityList[i]["city_name"],
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  TitleBookingMessage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 2, 0, 5),
      decoration: BoxDecoration(
        color: ColorPalette.whitasslight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20.0),
          Center(
            child: Icon(
              Icons.directions_bike,
              color: Colors.black,
              size: 40,
            ),
          ),
          SizedBox(height: 8.0),
          Center(
            child: Text(
              AS.WhatToEnjoyAdvnture(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 10.0),
          Center(
            child: Text(
              AS.MakeFunWithAdventureRide(),
              style: TextStyle(color: Colors.black, fontSize: 15.0),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10.0),
          Center(
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: BorderSide(color: ColorPalette.black, width: 1)),
              onPressed: () {
                Navigator.push(
                    context,
                    MyCustomRoute(
                        builder: (context) => BlogList()));
              },
              color: ColorPalette.white,
              textColor: ColorPalette.blacklight,
              child:
              Text(AS.ViewBlog().toUpperCase(), style: TextStyle(fontSize: 14)),
            ),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  LatestTitle() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 2, 20, 5),
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              AS.LatestPackage(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 5.0),
          Center(
            child: Container(
              width: 100,
              height: 2,
              color: ColorPalette.red,
            ),
          ),
        ],
      ),
    );
  }

  DashPackList(BuildContext context, List packageList) {
    return Padding(
      padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
      child: Container(
          width: MediaQuery.of(context).size.width,
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 5,
          children: [
            for (var i = 0; i < packageList.length; i++)
        CardDashPackList(context, i, packageList)
          ],
        )
      ),
    );
  }

  CardDashPackList(BuildContext context, int index, packageList) {
    return Container(
      width: (MediaQuery.of(context).size.width-20)*0.5,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
        padding: EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
        child: GestureDetector(
          onTap: () {
            _openProductView(
                packageList[index]["p_id"],
                packageList[index]["p_name"],
                packageList[index]["p_sub"],
                packageList[index]["p_image"],
                packageList[index]["vendor_id"]);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width*0.5,
                height: MediaQuery.of(context).size.width*0.3,
                child:  ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: FadeInImage(
                      image: NetworkImage(
                          Urls.imageLocation + packageList[index]["p_image"]),
                      placeholder: AssetImage(Urls.DummyImageBanner),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 130,
                      fit: BoxFit.cover,
                    )),
              ),

              SizedBox(height: 5.0),
              Text(
                "" + packageList[index]["p_name"],
                maxLines: 1,
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 3.0),
              RatingStars(
                  packageList[index]["ratings"], packageList[index]["count"]),
              SizedBox(height: 3.0),
              Text(
                "" +
                    packageList[index]["adultprice"].toString() +
                    " " +
                    Const.CURRENCY +
                    " ( " +
                    packageList[index]["days"].toString() +
                    " )",
                maxLines: 1,
                style: TextStyle(
                  color: ColorPalette.black2,
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ));
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
              "" + count + AS.Reviews(),
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
              "" + count + AS.Reviews(),
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
              "" + count + AS.Reviews(),
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
              "" + count +AS.Reviews(),
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
              "" + count + AS.Reviews(),
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
              "" + count + AS.Reviews(),
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
    }
    ;
  }
}



// Defines the content of the search page in `showSearch()`.
// SearchDelegate has a member `query` which is the query string.
class _MySearchDelegate extends SearchDelegate<String> {
  final List<String> _words;
  final List<String> _history;

  _MySearchDelegate(List<String> words)
      : _words = words,
        _history =words,
        super();

  // Leading icon in search bar.
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        // SearchDelegate.close() can return vlaues, similar to Navigator.pop().
        this.close(context, null);
      },
    );
  }

  // Widget of result page.
  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('You have selected the word:'),
            GestureDetector(
              onTap: () {
                // Returns this.query as result to previous screen, c.f.
                // `showSearch()` above.
                this.close(context, this.query);
              },
              child: Text(
                this.query,
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Suggestions list while typing (this.query).
  @override
  Widget buildSuggestions(BuildContext context) {
    final Iterable<String> suggestions = this.query.isEmpty
        ? _history
        : _words.where((word) => word.startsWith(query));

    return _SuggestionList(
      query: this.query,
      suggestions: suggestions.toList(),
      onSelected: (String suggestion) {
        this.query = suggestion;
        this._history.insert(0, suggestion);
        showResults(context);
      },
    );
  }

  // Action buttons at the right of search bar.
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )

    ];
  }
}

// Suggestions list widget displayed in the search page.
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? Icon(Icons.history) : Icon(null),
          // Highlight the substring that matched the query.
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style: textTheme.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: suggestion.substring(query.length),
                  style: textTheme,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
            Navigator.pushReplacement(
                context,
                MyCustomRoute(
                    builder: (context) => ProductListingScreen(
                      GetCity: suggestion,
                    )));

          },
        );
      },
    );
  }
}