import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/components/url_open.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/components/myDialog.dart';
import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/plugins_utils/alartmessage.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/screen/dashboard.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/screen/imagefullscreen.dart';



import 'package:erdifny/screen/paymentconform.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:http/http.dart' as http;

import 'package:erdifny/utils/urls.dart';

class ProductView extends StatefulWidget {
  @override
  _ProductViewState createState() {
    return _ProductViewState();
  }
}

class _ProductViewState extends State<ProductView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var pid, pname, psub, pimage,userId,pvendor;
  List  ProductDetail,ProductImageList,ProductRatings,CategoryList,TagLists,AminityList,CityRangeList;
  bool showProgress;
  String BookDate,BookedDateInt,VendorPercentage;
  Map data;
  int minChild,maxChild,minAdult,maxAdult;
  double childCost,adultCost;
  int liked;

  List<DateTime> unselectableDates=[];

  GoogleMapController _controller;

  conformpay() {
    SharedStoreUtils.setValue(Const.PCHILD_MIN, minChild.toString());
    SharedStoreUtils.setValue(Const.PCHILD_MAX, maxChild.toString());
    SharedStoreUtils.setValue(Const.PADULT_MIN, minAdult.toString());
    SharedStoreUtils.setValue(Const.PADULT_MAX, maxAdult.toString());
    SharedStoreUtils.setValue(Const.PCHILD_PRICE, childCost.toString());
    SharedStoreUtils.setValue(Const.PADULT_PRICE, adultCost.toString());
    SharedStoreUtils.setValue(Const.PBOOK_DATE, BookDate.toString());
    SharedStoreUtils.setValue(Const.PBOOK_DATE_INT, BookedDateInt.toString());
    SharedStoreUtils.setValue(Const.PVENDOR_PERCENT, VendorPercentage);

    Navigator.push(
        context, MyCustomRoute(builder: (context) => PaymentConform()));


  }

  @override
  void initState() {
    super.initState();
    getSharedStore();
    showProgress=false;
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pid = prefs.getString(Const.PREF_PID) ?? '';
      userId = prefs.getString(Const.PREF_USERID) ?? '';
      pname = prefs.getString(Const.PREF_PNAME) ?? '';
      psub = prefs.getString(Const.PREF_PSUB) ?? '';
      pimage = prefs.getString(Const.PREF_PIMAGE) ?? '';
      pvendor = prefs.getString(Const.PREF_PVENDOR) ?? '';
    });
    _getProductDetails();
  }

  _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    DateTime newDateTime = await showRoundedDatePicker(
      context: context,
      theme: ThemeData(
        primaryColor: ColorPalette.red,
        accentColor: ColorPalette.red,
        buttonColor: ColorPalette.red,
      ),
        imageHeader: AssetImage("assets/images/back1.jpg"),
      textPositiveButton: AS.BookNow(),
      textNegativeButton: AS.Cancel(),

      initialDate: DateTime.now().add(Duration(days:2)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 40)),

      borderRadius: 16,
        listDateDisabled: unselectableDates,
      onTapDay:  (DateTime dateTime, bool available){
        if (!available) {
          showDialog(
              context: context,
              builder: (c) => CupertinoAlertDialog(title: Text(AS.Thisdatecannotbeselected()),actions: <Widget>[
                CupertinoDialogAction(child: Text(AS.OK()),onPressed: (){
                  Navigator.pop(context);
                },)
              ],));
        }
        return available;
      }
    );

    if (newDateTime != null && newDateTime != selectedDate)
      setState(() {
        selectedDate = newDateTime;

        String sday,smonth,syear,sbooked;

        if(newDateTime.day<=9){
          sday="0"+newDateTime.day.toString();
        }else{
          sday=newDateTime.day.toString();
        }

        if(newDateTime.month<=9){
          smonth="0"+newDateTime.month.toString();
        }else{
          smonth=newDateTime.month.toString();
        }

        syear=newDateTime.year.toString();
        BookDate=sday+"-"+smonth+"-"+syear;
        BookedDateInt=syear+smonth+sday;

        String tempdate=syear+"-"+smonth+"-"+sday;
        var seldate=DateTime.parse(tempdate+"T14Z");
        if(unselectableDates.contains(seldate)){
          SnakeBarUtils.Error(_scaffoldKey, AS.Dateunavailable());
        }else{
          conformpay();
        }



      });

  }

  _getProductDetails() async {
    showProgress=true;
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput = '{"key": "' + Const.APPKEY +'","pid":"'+pid+'","uid":"'+userId+ '"}';
     debugPrint("" + jsonInput);
    final response =
    await http.post(Urls.ProductView, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);
    if(response.statusCode==200){
      showProgress=false;
      if (data["success"] == true) {
        setState(() {

          ProductDetail = data["product"];
          ProductImageList = data["productimage"];
          ProductRatings = data["productrating"];
          CategoryList = data["categoryitem"];
          TagLists = data["tagitem"];
          AminityList = data["aminityitem"];
          CityRangeList = data["cityRangeitem"];
          liked=data["likes"];
          VendorPercentage=ProductDetail[0]["admin_percent"];
          getUnavailabledates();
          debugPrint("ssss"+VendorPercentage);

        });
      }
    }
  }

  getUnavailabledates(){
    if(ProductDetail[0]["daterange"]!="" || ProductDetail[0]["daterange"]!=" "){
      var stringUnavail=ProductDetail[0]["daterange"];
      List arrUnavailablity = stringUnavail.split(',');
      for(int i=0;i<arrUnavailablity.length;i++){
        setState(() {
          unselectableDates.add(DateTime.parse(arrUnavailablity[i]+"T14Z"));
        });

      }
      debugPrint("datearray-"+unselectableDates.toString());
    }
  }
  _addLike() async {
    showProgress=true;
    Map<String, String> headers = {"Content-type": "application/json"};
    String jsonInput = '{"key": "' + Const.APPKEY +'","pid":"'+pid+'","uid":"'+userId+ '"}';
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
            body:    Container(
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
              if (CategoryList != null) Category(),
              SizedBox(
                height: 20,
              ),
              if (ProductImageList != null) VendorDetail(),
              SizedBox(
                height: 40,
              ),
              if (ProductImageList != null)SubTitle(),
              SizedBox(
                height: 50,
              ),
              MiddleTitle(AS.TRIPAMINITIES(),120.0),
              SizedBox(
                height: 10,
              ),
              if (ProductImageList != null) Aminity(),
              SizedBox(
                height: 50,
              ),
              MiddleTitle(AS.PERSONPERMITTED(),150.0),
              SizedBox(
                height: 10,
              ),
              if (ProductImageList != null)   Persons(),
              SizedBox(
                height: 1,
              ),
              if (ProductImageList != null) ProductImages(context, ProductImageList),
              SizedBox(
                height: 30,
              ),
              MiddleTitle(AS.CITIESINCLUDED(),150.0),
              SizedBox(
                height: 5,
              ),
              if (CityRangeList != null) CityRange(),
              SizedBox(
                height: 40,
              ),
              MiddleTitle(AS.MOREABOUT(),150.0),
              SizedBox(
                height: 5,
              ),
              if (ProductImageList != null)ImportantNote(),
              if (TagLists != null) Tags(),
              SizedBox(
                height: 40,
              ),
              if (ProductDetail != null && ProductDetail[0]["location"]!="")mapView(),
              SizedBox(
                height: 30,
              ),
              MiddleTitle(AS.USERREVIEWS(),100.0),
              SizedBox(
                height: 10,
              ),
              if (ProductRatings != null) UserRatings(context, ProductRatings),
              SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
        BottomPriceTag(),
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
          mainAxisAlignment: MainAxisAlignment.end,
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

            Expanded(
              child: Container(
                child: Text(
                  pname,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),

            IconButton(
              icon: FaIcon(FontAwesomeIcons.whatsapp,color: Colors.black.withOpacity(0.5),),
              onPressed: () async {
                UrlOpenUtils.whatsapp(_scaffoldKey);
              },
            ),
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
            image: NetworkImage(Urls.imageLocation + pimage.toString()),
            placeholder: AssetImage(Urls.DummyImageBanner),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
            height: 350,
          ),
//          Container(
//              width: MediaQuery.of(context).size.width,
//              height: 350,
//              decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                      begin: Alignment.bottomCenter,
//                      end: Alignment.topCenter,
//                      colors: [
//                    ColorPalette.black_opacity,
//                    ColorPalette.black_hide
//                  ])),
//              ),
          if(ProductDetail!=null)Positioned(
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
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "" + pname,
                              style: TextStyle(
                                color: ColorPalette.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  color: ColorPalette.whitmild,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    ProductDetail[0]["city_name"].toString(),
                                    style: TextStyle(
                                      color: ColorPalette.whitmild,
                                      fontSize: 15.0,
                                    ),
                                    textAlign: TextAlign.left,
                                    softWrap: true,
                                    maxLines: 1,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if(liked==0)IconButton(
                      icon: Icon(Icons.favorite_border),
                      iconSize: 30,
                      hoverColor: ColorPalette.black_opacity_overy,
                      color: ColorPalette.white,
                      onPressed: () {
                        _addLike();
                      },
                    ),
                    if(liked!=0)IconButton(
                      icon: Icon(Icons.favorite),
                      iconSize: 30,
                      hoverColor: ColorPalette.red,
                      color: ColorPalette.red,
                      onPressed: () {
                        _addLike();
                      },
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

  GoBackButton() {
    return Positioned(
      left: 7,
      top: 10,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
            )),
        child: Center(
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 20,
            hoverColor: ColorPalette.black_opacity_overy,
            color: ColorPalette.blacklight,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  Category() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 5,
          children: <Widget>[
            for (var i = 0; i < CategoryList.length; i++)
              Chip(
                backgroundColor: ColorPalette.red.withOpacity(0.8),
                label: Text(CategoryList[i].toString(),style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                )),
              ),
          ],
        ));
  }
  VendorDetail() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ProductDetail[0]["city_name"].toString(),
                    style: TextStyle(
                      color: ColorPalette.TextColorTitle,
                      fontSize: 17.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    ProductDetail[0]["p_name"].toString(),
                    style: TextStyle(
                      color: ColorPalette.TextColorRegular,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: FadeInImage(
                image: NetworkImage(Urls.imageLocation + ProductDetail[0]["p_image"].toString()),
                placeholder: AssetImage(Urls.DummyImageBanner),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )),
        ],
      ),
    );
  }

  SubTitle() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              ProductDetail[0]["p_sub"].toString(),
              style: TextStyle(
                color: Colors.teal,
                fontSize: 25.0,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              ProductDetail[0]["p_detail"].toString(),
              style: TextStyle(
                color: ColorPalette.TextColorTitle,
                fontSize: 17.0,
              ),
              textAlign: TextAlign.left,
            )
          ],
        ));
  }
  MiddleTitle(var title,var dashsize) {
    if(ProductDetail!=null){
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 2, 20, 5),
        decoration: BoxDecoration(
          color: ColorPalette.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),

          ],
        ),
      );
    }else{
      return Visibility(
        visible: false,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20, 2, 20, 5),
          decoration: BoxDecoration(
            color: ColorPalette.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    color: Colors.teal,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),

            ],
          ),
        )
      );
    }
  }
  Aminity() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 10,
          children: <Widget>[
            for (var i = 0; i < AminityList.length; i++)
              OutlineButton(
                child: Text(AminityList[i]["amn_name"].toString(),
                    style: TextStyle(
                      color: ColorPalette.TextColorRegular,
                      fontSize: 12.0,
                    )),
                onPressed: () {
                  AlertUtils.showText(AminityList[i]["amn_name"].toString(),AminityList[i]["amn_detail"].toString(),"Close", context);
                  }, //callback when button is clicked
                borderSide: BorderSide(
                  color: ColorPalette.TextColorRegular, //Color of the border
                  style: BorderStyle.solid, //Style of the border
                  width: 0.8, //width of the border
                ),
              ),
          ],
        ));
  }

  CityRange() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 10,
          children: <Widget>[
            for (var i = 0; i < CityRangeList.length; i++)
              OutlineButton(
                child: Text(CityRangeList[i].toString(),
                    style: TextStyle(
                      color: ColorPalette.TextColorRegular,
                      fontSize: 12.0,
                    )),
          //callback when button is clicked
                borderSide: BorderSide(
                  color: ColorPalette.TextColorRegular, //Color of the border
                  style: BorderStyle.solid, //Style of the border
                  width: 0.8, //width of the border
                ),
                onPressed: (){},
              ),
          ],
        ));
  }
  Persons() {
    return  Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 2, 20, 5),
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.child_friendly,
                color: ColorPalette.black,
                size: 25,
              ),
              SizedBox(width: 10,),
              Text(
                AS.CHILDREN(),
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 18.0,),
                textAlign: TextAlign.left,
              )

            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              SizedBox(width: 40,),
              Icon(
                Icons.supervisor_account,
                color: ColorPalette.TextColorRegular,
                size: 20,
              ),
              SizedBox(width: 10,),

              Text(
                AS.Count(),
                style: TextStyle(
                  color: ColorPalette.TextColorTitle,
                  fontSize: 18.0,),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 10,),
              _childCount(),


            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              SizedBox(width: 40,),
              Icon(
                Icons.account_balance_wallet,
                color: ColorPalette.TextColorRegular,
                size: 20,
              ),
              SizedBox(width: 10,),
              Text(
                AS.Price2(),
                style: TextStyle(
                  color: ColorPalette.TextColorTitle,
                  fontSize: 18.0,),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 10,),
              _childPrice(),

            ],
          ),

          SizedBox(height: 20,),
          Row(
            children: <Widget>[
              Icon(
                Icons.person,
                color: ColorPalette.black,
                size: 25,
              ),
              SizedBox(width: 10,),
              Text(
                AS.ADULT(),
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 18.0,),
                textAlign: TextAlign.left,
              )

            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              SizedBox(width: 40,),
              Icon(
                Icons.supervisor_account,
                color: ColorPalette.TextColorRegular,
                size: 20,
              ),
              SizedBox(width: 10,),
              Text(
                AS.Count(),
                style: TextStyle(
                  color: ColorPalette.TextColorTitle,
                  fontSize: 18.0,),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 10,),
              _adultCount(),


            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              SizedBox(width: 40,),
              Icon(
                Icons.account_balance_wallet,
                color: ColorPalette.TextColorRegular,
                size: 20,
              ),
              SizedBox(width: 10,),
              Text(
                AS.Price2(),
                style: TextStyle(
                  color: ColorPalette.TextColorTitle,
                  fontSize: 18.0,),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 10,),
              _adultPrice(),

            ],
          ),
        ],
      ),
    );
  }

  ImportantNote() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 2, 20, 5),
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            ProductDetail[0]["notes"],
            style: TextStyle(
              color: ColorPalette.TextColorRegular,
              fontSize: 15.0,),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              SizedBox(width: 5,),
              Icon(
                Icons.access_time,
                color: ColorPalette.TextColorRegular,
                size: 20,
              ),
              SizedBox(width: 10,),
              Text(
                AS.Time2(),
                style: TextStyle(
                  color: ColorPalette.TextColorTitle,
                  fontSize: 15.0,),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 10,),
              Text(
                ProductDetail[0]["days"],
                style: TextStyle(
                  color: ColorPalette.TextColorRegular,
                  fontSize: 15.0,),
                textAlign: TextAlign.left,
              )

            ],
          ),
          SizedBox(height: 10,),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 5,),
              Icon(
                Icons.location_on,
                color: ColorPalette.TextColorRegular,
                size: 20,
              ),
              SizedBox(width: 10,),
              Text(
                AS.Meet2(),
                style: TextStyle(
                  color: ColorPalette.TextColorTitle,
                  fontSize: 15.0,),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Text(
                  ProductDetail[0]["meeting"],
                  style: TextStyle(
                    color: ColorPalette.TextColorRegular,
                    fontSize: 15.0,),
                  textAlign: TextAlign.left,
                ),
              )

            ],
          ),
        ],
      ),
    );
  }
  Tags() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 5,
          children: <Widget>[
            for (var i = 0; i < TagLists.length; i++)
              Chip(
                backgroundColor: ColorPalette.red.withOpacity(0.8),
                label: Text(TagLists[i].toString(),style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                )),
              ),
          ],
        ));
  }
  ProductImages(BuildContext context, List cityList) {
    return Padding(
      padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
      child: Container(
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: (1 / 0.7),
          controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: List<Widget>.generate(cityList.length, (index) {
            return CardImageList(context, index, cityList);
          }),
        ),
      ),
    );
  }
  CardImageList(BuildContext context, int i, List cityList) {
    return Container(
        padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 10),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context, MyCustomRoute(builder: (context) => ImageFullScreen(imgurl: Urls.imageLocation + cityList[i]["pi_image"].toString(),)));
          },
          child: Material(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            child: FadeInImage(
              image: NetworkImage(
                  Urls.imageLocation + cityList[i]["pi_image"]),
              placeholder: AssetImage(Urls.DummyImageBanner),
              width: MediaQuery.of(context).size.width * 0.9,
              height: 200,
              fit: BoxFit.cover,
            )
          ),
        ));
  }

  _childCount() {
    if(ProductDetail[0]["minchild"]=='0'){
      setState(() {
        minChild=0;
        maxChild=0;
      });
      return Text(
        AS.ChildrensNotAllowed(),
        style: TextStyle(
          color: ColorPalette.TextColorRegular,
          fontSize: 15.0,),
        textAlign: TextAlign.left,
      );
    }else{
      if(ProductDetail[0]["maxchild"]==null || ProductDetail[0]["maxchild"]=="0"){
        setState(() {
          minChild=int.parse(ProductDetail[0]["minchild"]);
          maxChild=20;
        });
        return Text(
          ProductDetail[0]["minchild"]+"  "+AS.Minimum(),
          style: TextStyle(
            color: ColorPalette.TextColorRegular,
            fontSize: 15.0,),
          textAlign: TextAlign.left,
        );
      }else{
        setState(() {
          minChild=int.parse(ProductDetail[0]["minchild"]);
          maxChild=int.parse(ProductDetail[0]["maxchild"]);
        });
        return Text(
          ProductDetail[0]["minchild"]+" - "+ProductDetail[0]["maxchild"]+" "+AS.Maximum(),
          style: TextStyle(
            color: ColorPalette.TextColorRegular,
            fontSize: 15.0,),
          textAlign: TextAlign.left,
        );
      }

    }
  }

  _adultCount() {
    if(ProductDetail[0]["minadult"]=='0'){
      setState(() {
        minAdult=0;
        maxAdult=0;
      });
      return Text(
        AS.AdultNotAllowed(),
        style: TextStyle(
          color: ColorPalette.TextColorRegular,
          fontSize: 15.0,),
        textAlign: TextAlign.left,
      );
    }else{
      if(ProductDetail[0]["maxadult"]==null || ProductDetail[0]["maxadult"]=="0"){
        setState(() {
          minAdult=int.parse(ProductDetail[0]["minadult"]);
          maxAdult=20;
        });
        return Text(
          ProductDetail[0]["minadult"]+"  "+AS.Minimum(),
          style: TextStyle(
            color: ColorPalette.TextColorRegular,
            fontSize: 15.0,),
          textAlign: TextAlign.left,
        );
      }else{
        setState(() {
          minAdult=int.parse(ProductDetail[0]["minadult"]);
          maxAdult=int.parse(ProductDetail[0]["maxadult"]);
        });

        return Text(
          ProductDetail[0]["minadult"]+" - "+ProductDetail[0]["maxadult"]+" "+AS.Maximum(),
          style: TextStyle(
            color: ColorPalette.TextColorRegular,
            fontSize: 15.0,),
          textAlign: TextAlign.left,
        );
      }

    }
  }

  _childPrice() {
    if(ProductDetail[0]["minchild"]=='0'){
      setState(() {
        childCost=0;
      });
      return Text(
        " -- ",
        style: TextStyle(
          color: ColorPalette.TextColorRegular,
          fontSize: 15.0,),
        textAlign: TextAlign.left,
      );
    }else{
      setState(() {
        childCost=double.parse(ProductDetail[0]["childprice"]);
      });
      return Text(
        ProductDetail[0]["childprice"]+" "+Const.CURRENCY,
        style: TextStyle(
          color: ColorPalette.TextColorRegular,
          fontSize: 15.0,),
        textAlign: TextAlign.left,
      );
    }
  }
  _adultPrice() {
    if(ProductDetail[0]["minadult"]=='0'){
      setState(() {
        adultCost=0;
      });
      return Text(
        " -- ",
        style: TextStyle(
          color: ColorPalette.TextColorRegular,
          fontSize: 15.0,),
        textAlign: TextAlign.left,
      );
    }else{
      setState(() {
        adultCost=double.parse(ProductDetail[0]["adultprice"]);
      });
      return Text(
        ProductDetail[0]["adultprice"]+" "+Const.CURRENCY,
        style: TextStyle(
          color: ColorPalette.TextColorRegular,
          fontSize: 15.0,),
        textAlign: TextAlign.left,
      );
    }
  }

  UserRatings(BuildContext context, List ratingList) {
    return Padding(
      padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
      child: Column(
        children: <Widget>[
          for(var  i=0; i<ratingList.length;i++)CardUserRatings(context, i, ratingList)
        ],
      ),
    );
  }
  CardUserRatings(BuildContext context, int i, List ratingList) {
    return Container(
        padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.person),
              iconSize: 30,
              hoverColor: ColorPalette.black_opacity_overy,
              color: ColorPalette.TextColorRegular,
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "" + ratingList[i]["name"],
                      style: TextStyle(
                        color: ColorPalette.TextColorTitle,
                        fontSize: 15.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 5,),
                    Text(
                      "" + ratingList[i]["r_commend"],
                      style: TextStyle(
                        color: ColorPalette.TextColorRegular,
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 5,),
                    if(ratingList[i]["r_image"]!="")FadeInImage(
                      image: NetworkImage(Urls.imageLocation + ratingList[i]["r_image"]),
                      placeholder: AssetImage(Urls.DummyImageBanner),
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(height: 5,),
                    RatingStars(ratingList[i]["r_stars"]),
                    SizedBox(height: 10,),

                  ],
                ),
              ),
            ),

          ],
        ));
  }

  RatingStars(var ratings) {
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
          ],
        );
        break;
    }
    ;
  }

  BottomPriceTag() {
    if(ProductDetail!=null){
      return Positioned(
        bottom: 0,
        left: 0,
        child: Material(
          elevation: 2,
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            height: 70,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 15.0,
                      offset: Offset(0.0, 4)
                  )
                ],
                color: Colors.white
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,


              children: <Widget>[
                if (ProductImageList != null) Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          Row(
                            children: <Widget>[
                              Icon(Icons.account_balance_wallet,
                                color: ColorPalette.TextColorRegular,
                                size: 20,),
                              SizedBox(width: 10,),
                              Text(
                                ProductDetail[0]["adultprice"]+" "+Const.CURRENCY,
                                style: TextStyle(
                                  color: ColorPalette.TextColorTitle,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(width: 5,),
                              Text(" ( "+ProductDetail[0]["days"] +" )",
                                style: TextStyle(
                                  color: ColorPalette.TextColorTitle,
                                  fontSize: 12.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: <Widget>[
                              RatingStars(ProductDetail[0]["ratings"]),
                              SizedBox(width: 10,),
                              Text(
                                ProductDetail[0]["count"]+" "+AS.Reviews(),
                                style: TextStyle(
                                  color: ColorPalette.TextColorTitle,
                                  fontSize: 12.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),


                        ],
                      ),
                    )),
                SizedBox(width: 20,),
                if (ProductImageList != null) RaisedButton(child: Text(AS.CheckOut()),
                  onPressed: (){
               //     conformpay();
                    //   _settingModalBottomSheet(context);
                  //  _dateselect(context);
                    _selectDate(context);

                  },
                  color: ColorPalette.red,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  splashColor: Colors.grey,
                ),


              ],
            ),
          ),
        ),
      );
    }else{
      return Visibility(
        visible: false,
        child: Positioned(
          bottom: 0,
          left: 0,
          child: Material(
            elevation: 2,
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              height: 70,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 15.0,
                        offset: Offset(0.0, 4)
                    )
                  ],
                  color: Colors.white
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,


                children: <Widget>[
                  if (ProductImageList != null) Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                            Row(
                              children: <Widget>[
                                Icon(Icons.account_balance_wallet,
                                  color: ColorPalette.TextColorRegular,
                                  size: 20,),
                                SizedBox(width: 10,),
                                Text(
                                  ProductDetail[0]["adultprice"]+" "+Const.CURRENCY,
                                  style: TextStyle(
                                    color: ColorPalette.TextColorTitle,
                                    fontSize: 15.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(width: 5,),
                                Text(" ( "+ProductDetail[0]["days"] +" )",
                                  style: TextStyle(
                                    color: ColorPalette.TextColorTitle,
                                    fontSize: 12.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: <Widget>[
                                RatingStars(ProductDetail[0]["ratings"]),
                                SizedBox(width: 10,),
                                Text(
                                  ProductDetail[0]["count"]+" "+AS.Reviews(),
                                  style: TextStyle(
                                    color: ColorPalette.TextColorTitle,
                                    fontSize: 12.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),


                          ],
                        ),
                      )),
                  SizedBox(width: 20,),
                  if (ProductImageList != null) RaisedButton(child: Text(AS.CheckOut()),
                    onPressed: (){
                    //  conformpay();
                      //   _settingModalBottomSheet(context);
                      _dateselect(context);
                    },
                    color: Colors.teal,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    splashColor: Colors.grey,
                  ),


                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  _settingModalBottomSheet(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: <Widget>[
                ListTile(
                    leading: new Icon(Icons.music_note),
                    title: new Text('Music'),
                    onTap: () => {}
                ),
                ListTile(
                  leading: new Icon(Icons.videocam),
                  title: new Text('Video'),
                  onTap: () => {},
                ),

              ],
            ),
          );
        }
    );
  }

  _dateselect(context){
    Future<DateTime> selectedDate = showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 2)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 40)),
      selectableDayPredicate: (DateTime val)  {
        String sanitized = sanitizeDateTime(val);
        return !unselectableDates.contains(sanitized);
      },
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
  }


  String sanitizeDateTime(DateTime dateTime) => "${dateTime.year}-${dateTime.month}-${dateTime.day}";

  Set<String> getDateSet(List<DateTime> dates) => dates.map(sanitizeDateTime).toSet();



  mapView() {

    var stringLocation=ProductDetail[0]["location"];
    var arrLocation = stringLocation.split(',');
    double mapLat= double.parse(arrLocation[0]);
    double mapLng= double.parse(arrLocation[1]);
    return Column(children: <Widget>[
      MiddleTitle(AS.MAPLOCATION(),"20"),
      Container(
        padding: EdgeInsets.fromLTRB(15, 7, 15, 10),
        height: 300,
        width: MediaQuery.of(context).size.width,

        child:  GoogleMap(
          mapType: MapType.normal,
          markers: _createMarker(mapLat, mapLng),
          initialCameraPosition: CameraPosition(
            target: LatLng(mapLat, mapLng),
            zoom: 15.0,
          ),
          onMapCreated: (GoogleMapController controller){
            _controller=controller;
          },
        ),
      )
    ],);
  }

  Set<Marker> _createMarker(double mapLat,double mapLng){
    return <Marker>[
      Marker(
        markerId: MarkerId("Point"),
        position: LatLng(mapLat, mapLng),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "Point")
      ),
    ].toSet();
  }



}
