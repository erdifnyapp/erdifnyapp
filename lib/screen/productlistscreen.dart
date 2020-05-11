import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/components/url_open.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/screen/productview.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;

class ProductListingScreen extends StatefulWidget {
  String GetCity="";
  ProductListingScreen({Key key,this.GetCity}) : super(key: key);

  @override
  _ProductListingScreenState createState() {
    return _ProductListingScreenState(GetCity);
  }
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  ScrollController _scrollController = new ScrollController();
  List PackageList = new List();
  int pageCount = 1;
  Map data, dataFilter;
  bool showProgress = false;
  String City="";

  List aminityList = [];
  List aminityListSelect = [];
  String aminityFinal="";

  List ratingSelected=[];
  String ratingFinal="";

  List categoryList = [];
  List categoryListSelect = [];
  String categoryFinal="";

  List tagList = [];
  List tagListSelected = [];
  String tagFinal="";
  String TodayDate="";
  String TomorrowDate="";
  String SelectedDate="";
  String Popular="";

  double MinPrice = 0.0;
  double MaxPrice = 200000.0;
  var PriceRange = RangeValues(0, 200000);
  int responseStatus=0;

  _ProductListingScreenState(this.City);

  @override
  void initState() {
    super.initState();
    _getFilters();
    _getDashboardItems(pageCount);
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

  _getDashboardItems(int getPage) async {
    showProgress = true;
    setState(() {

      responseStatus=0;
    });
    Map<String, String> headers = {"Content-type": "application/json"};
    String jsonInput = '{"key": "' +
        Const.APPKEY +
        '","page":"' + getPage.toString() +
        '","aminity":"' +aminityFinal +
        '","city":"' +City +
        '","category":"' +categoryFinal +
        '","tag":"' +tagFinal +
        '","minprice":"' +MinPrice.toString() +
        '","maxprice":"' +MaxPrice.toString() +
        '","ratings":"' +ratingFinal +
        '","today":"' +TodayDate +
        '","tomorrow":"' +TomorrowDate +
        '","selectdate":"' +SelectedDate +
        '","popular":"' +Popular +
        '"}';
    debugPrint("URL--" + jsonInput);
    final response =
        await http.post(Urls.PackList, headers: headers, body: jsonInput);
    data = json.decode(response.body);
    List tempList = new List();
    for (int i = 0; i < data["packlist"].length; i++) {
      tempList.add(data["packlist"][i]);
    }

    if (data["success"] == true) {
      setState(() {
        showProgress = false;
        responseStatus=200;
        PackageList.addAll(tempList);
      });
    }

    //   debugPrint("City--"+CityList.toString());
  }

  _getFilters() async {
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput = '{"key": "' + Const.APPKEY + '"}';
    debugPrint("URL--" + jsonInput);

    final response =
        await http.post(Urls.Filters, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    dataFilter = json.decode(response.body);

    if (dataFilter["success"] == true) {
      setState(() {
        aminityList = dataFilter["aminity"];
        categoryList = dataFilter["category"];
        tagList = dataFilter["tags"];
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
    return MaterialApp(
      theme: ThemeData(fontFamily: "Calibra"),
      home: SafeArea(
        child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            color: ColorPalette.red,
          ),
          child: _appBody(),
        ),
      ),),
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
              FilterList(),
              if (PackageList.length==0 && responseStatus==200) ShowImageEmpty(),

              PackageListing(),
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
      height: 65,
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(icon: Icon(Icons.arrow_back,color: Colors.black87,size: 25,),onPressed: (){
              Navigator.of(context).pop(true);

            },),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                "Erdifny",
                style: TextStyle(color: Colors.black87, fontSize: 22.0,fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: 5,
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

  FilterList() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
      height: 50,
      child: Row(
        children: <Widget>[
          new Flexible(
            child: new CustomScrollView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              slivers: <Widget>[
                new SliverList(
                  delegate: new SliverChildListDelegate(
                    <Widget>[
//                      if (aminityFinal == "")
//                        OutlineButton.icon(
//                          icon: Icon(Icons.card_travel,color: ColorPalette.TextColorRegular,size: 20,),
//                          label: Text(AS.Aminity(),
//                              style: TextStyle(
//                                color: ColorPalette.TextColorRegular,
//                                fontSize: 12.0,
//                              )),
//                          onPressed: () {
//                            _showAminity();
//                          }, //callback when button is clicked
//                          borderSide: BorderSide(
//                            color: ColorPalette.TextColorRegular,
//                            style: BorderStyle.solid, //Style of the border
//                            width: 0.8, //width of the border
//                          ),
//                        ),
//                      if (aminityFinal != "")
//                      RaisedButton.icon(onPressed: () {
//                        _showAminity();
//                      }, icon: Icon(Icons.card_travel,color: Colors.white,size: 20,),  label: Text("Aminity",
//                          style: TextStyle(
//                            color: Colors.white,
//                            fontSize: 12.0,
//                          )),
//                      color: ColorPalette.red,),
//                      SizedBox(
//                        width: 15,
//                      ),
                      if (Popular == "")
                        OutlineButton.icon(
                          icon: Icon(Icons.language,color: ColorPalette.TextColorRegular,size: 20,),
                          label: Text(AS.Popular(),
                              style: TextStyle(
                                color: ColorPalette.TextColorRegular,
                                fontSize: 12.0,
                              )),
                          onPressed: () {
                            SetPopular();
                          }, //callback when button is clicked
                          borderSide: BorderSide(
                            color: ColorPalette.TextColorRegular,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                        ),
                      if (Popular != "")
                        RaisedButton.icon(onPressed: () {
                          CleartPopular();
                        }, icon: Icon(Icons.language,color: Colors.white,size: 20,),  label: Text(AS.Popular(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            )),
                          color: ColorPalette.red,),
                      SizedBox(
                        width: 15,
                      ),
                      if (MinPrice == 0.0 && MaxPrice == 200000.0)
                        OutlineButton.icon(
                          icon: Icon(Icons.monetization_on,color: ColorPalette.TextColorRegular,size: 20,),
                          label: Text(AS.Price(),
                              style: TextStyle(
                                color: ColorPalette.TextColorRegular,
                                fontSize: 12.0,
                              )),
                          onPressed: () {
                            _showPrice(context);
                          }, //callback when button is clicked
                          borderSide: BorderSide(
                            color: ColorPalette.TextColorRegular,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                        ),
                      if (MinPrice != 0.0 || MaxPrice != 200000.0)
                      RaisedButton.icon(onPressed: () {
                        _showPrice(context);
                      }, icon: Icon(Icons.monetization_on,color: Colors.white,size: 20,),  label: Text(AS.Price(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          )),
                        color: ColorPalette.red,),
                      SizedBox(
                        width: 15,
                      ),
                      if (ratingFinal == "")
                        OutlineButton.icon(
                          icon: Icon(Icons.star,color: ColorPalette.TextColorRegular,size: 20,),
                          label: Text(AS.Ratings(),
                              style: TextStyle(
                                color: ColorPalette.TextColorRegular,
                                fontSize: 12.0,
                              )),
                          onPressed: () {
                            _showRating();
                          }, //callback when button is clicked
                          borderSide: BorderSide(
                            color: ColorPalette.TextColorRegular,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                        ),
                      if (ratingFinal != "")
                        RaisedButton.icon(onPressed: () {
                          _showRating();
                        }, icon: Icon(Icons.star,color: Colors.white,size: 20,),  label: Text(AS.Ratings(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            )),
                          color: ColorPalette.red,),
                      SizedBox(
                        width: 15,
                      ),
                      if (categoryFinal == "")
                        OutlineButton.icon(
                          icon: Icon(Icons.filter_hdr,color: ColorPalette.TextColorRegular,size: 20,),
                          label: Text(AS.Category(),
                              style: TextStyle(
                                color: ColorPalette.TextColorRegular,
                                fontSize: 12.0,
                              )),
                          onPressed: () {
                            _showCategory();
                          }, //callback when button is clicked
                          borderSide: BorderSide(
                            color: ColorPalette.TextColorRegular,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                        ),
                      if (categoryFinal != "")
                        RaisedButton.icon(onPressed: () {
                          _showCategory();
                        }, icon: Icon(Icons.filter_hdr,color: Colors.white,size: 20,),  label: Text(AS.Category(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            )),
                          color: ColorPalette.red,),
                      SizedBox(
                        width: 15,
                      ),
                      if (tagFinal == "")
                        OutlineButton.icon(
                          icon: Icon(Icons.near_me,color: ColorPalette.TextColorRegular,size: 20,),
                          label: Text(AS.Tag(),
                              style: TextStyle(
                                color: ColorPalette.TextColorRegular,
                                fontSize: 12.0,
                              )),
                          onPressed: () {
                            _showTag();
                          }, //callback when button is clicked
                          borderSide: BorderSide(
                            color: ColorPalette.TextColorRegular,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                        ),
                      if (tagFinal != "")
                      RaisedButton.icon(onPressed: () {
                        _showTag();
                      }, icon: Icon(Icons.near_me,color: Colors.white,size: 20,),  label: Text(AS.Tag(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          )),
                        color: ColorPalette.red,),
                      SizedBox(
                        width: 15,
                      ),
                      if (TodayDate == "")
                        OutlineButton.icon(
                          icon: Icon(Icons.date_range,color: ColorPalette.TextColorRegular,size: 20,),
                          label: Text(AS.Today(),
                              style: TextStyle(
                                color: ColorPalette.TextColorRegular,
                                fontSize: 12.0,
                              )),
                          onPressed: () {
                            SetToday();
                          }, //callback when button is clicked
                          borderSide: BorderSide(
                            color: ColorPalette.TextColorRegular,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                        ),
                      if (TodayDate != "")
                        RaisedButton.icon(onPressed: () {
                          CleartToday();
                        }, icon: Icon(Icons.date_range,color: Colors.white,size: 20,),  label: Text(AS.Today(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            )),
                          color: ColorPalette.red,),
                      SizedBox(
                        width: 15,
                      ),
                      if (TomorrowDate == "")
                        OutlineButton.icon(
                          icon: Icon(Icons.calendar_today,color: ColorPalette.TextColorRegular,size: 20,),
                          label: Text(AS.Tomorrow(),
                              style: TextStyle(
                                color: ColorPalette.TextColorRegular,
                                fontSize: 12.0,
                              )),
                          onPressed: () {
                            SetTomorrow();
                          }, //callback when button is clicked
                          borderSide: BorderSide(
                            color: ColorPalette.TextColorRegular,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                        ),
                      if (TomorrowDate != "")
                        RaisedButton.icon(onPressed: () {
                          CleartTomorrow();
                        }, icon: Icon(Icons.calendar_today,color: Colors.white,size: 20,),  label: Text("Tomorrow",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            )),
                          color: ColorPalette.red,),
                      SizedBox(
                        width: 15,
                      ),
                      if (SelectedDate == "")
                        OutlineButton.icon(
                          icon: Icon(Icons.calendar_today,color: ColorPalette.TextColorRegular,size: 20,),
                          label: Text(AS.Dated(),
                              style: TextStyle(
                                color: ColorPalette.TextColorRegular,
                                fontSize: 12.0,
                              )),
                          onPressed: () {
                            SetDated(context);
                          }, //callback when button is clicked
                          borderSide: BorderSide(
                            color: ColorPalette.TextColorRegular,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                        ),
                      if (SelectedDate != "")
                        RaisedButton.icon(onPressed: () {
                          CleartDated();
                        }, icon: Icon(Icons.calendar_today,color: Colors.white,size: 20,),  label: Text(AS.Dated(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            )),
                          color: ColorPalette.red,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PackageListing() {
    return Container(
      height: MediaQuery.of(context).size.height - 100,
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
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        fit: BoxFit.cover,
                      )),
                  SizedBox(height: 7.0),
                  Row(
                    children: <Widget>[
                      Text(
                        PackageList[index]["days"]
                            .toString()
                            .toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12.0,),
                        textAlign: TextAlign.left,
                      ),

                      Text(
                        " . " + PackageList[index]["city_name"].toString().toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(height: 3.0),
                  Text(
                    "" + PackageList[index]["p_name"],
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 5.0),
                  RatingStars(PackageList[index]["ratings"],
                      PackageList[index]["count"]),
                  SizedBox(height: 3.0),
                  Row(
                    children: <Widget>[
                      Text("from ",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12.0,),
                        textAlign: TextAlign.left,
                      ),

                      Text(
                        "" + PackageList[index]["adultprice"]+" AED".toString().toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
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
              "" + count + " "+AS.Ratings(),
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
              "" + count + " "+AS.Ratings(),
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
              "" + count + " "+AS.Ratings(),
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
              "" + count + " "+AS.Ratings(),
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
              "" + count + " "+AS.Ratings(),
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
              "" + count + " "+AS.Ratings(),
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



  //Aminity Start

  _showAminity() {
    return showModalBottomSheet(

        context: context,
        builder: (BuildContext bc) {
          return Stack(
            children: <Widget>[


              SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(5, 50, 5, 50),
                  child: new Wrap(
                    children: <Widget>[
                      for (var i = 0; i < aminityList.length; i++)
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  aminityList[i]["amn_name"],
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) =>
                                    Checkbox(
                                        value: getAminity(aminityList[i]["amn_id"]),
                                        checkColor: ColorPalette.red,
                                        activeColor: Colors.white,
                                        onChanged: (bool newValue) {
                                          setAminitySelection(aminityList[i]["amn_id"], newValue, setState);
                                        }),
                              ),

                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      IconButton(icon: Icon(Icons.clear,color: Colors.black87,size: 25,),onPressed: (){
                        Navigator.of(context).pop(true);
                      },),
                      Expanded(child:
                      Text(AS.AminityFilter(),style: TextStyle(color: Colors.black87,fontSize: 18),),),

                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Expanded(
                        child: RaisedButton(onPressed:(){setAminityClear();} ,child: Text(AS.Clear(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.ass_dark,)
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                          child: RaisedButton(onPressed:(){setAminityApply();} ,child: Text(AS.Apply(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.red,)
                      ),



                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
  getAminity(var amnid) {
    if (aminityListSelect.contains(amnid)) {
      return true;
    } else {
      return false;
    }
  }

  setAminitySelection(String amnid, bool amnval,StateSetter state) {
    if (amnval) {
      if (aminityListSelect.contains(amnid)) {
      } else {
        state(() {
          aminityListSelect.add(amnid);
        });
      }
    } else {
      if (aminityListSelect.contains(amnid)) {
        state(() {
          aminityListSelect.removeAt(aminityListSelect.indexOf(amnid));
        });
      } else {}
    }
  }


  setAminityClear() {
    Navigator.of(context).pop(true);
    setState(() {
      aminityListSelect.clear();
      aminityFinal="";
      _getDashboardItems(1);
    });
  }

  setAminityApply() {
    Navigator.of(context).pop(true);
    setState(() {
      for(int i=0;i<aminityListSelect.length;i++){
        aminityFinal=aminityFinal+aminityListSelect[i].toString()+",";
      }
      aminityFinal=aminityFinal.substring(0, aminityFinal.length - 1);
      debugPrint("aminity"+aminityFinal);
      PackageList.clear();
      _getDashboardItems(1);
    });
  }


  //Price Start
  _showPrice(BuildContext mcontext) {
    return showModalBottomSheet(
        context: mcontext,
        builder: (mcontext) {
          return StatefulBuilder(
            builder: (mcontext, setState) {
              return SingleChildScrollView(
                child: Container(
                  child: new Wrap(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            IconButton(icon: Icon(Icons.clear,color: Colors.black87,size: 25,),onPressed: (){
                              Navigator.of(context).pop(true);
                            },),
                            Expanded(child:
                            Text(AS.PriceFilter(),style: TextStyle(color: Colors.black87,fontSize: 18),),),

                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(15, 30, 15, 40),
                          child: StatefulBuilder(builder: (mcontext, setState) {
                            return RangeSlider(
                              min: 0.0,
                              max: 200000.0,
                              divisions: 50,
                              values: PriceRange,
                              onChanged: (RangeValues newRange) {
                                setState(() {
                                  PriceRange = newRange;
                                  MinPrice = PriceRange.start.roundToDouble();
                                  MaxPrice = PriceRange.end.roundToDouble();
                                });
                              },
                              labels: RangeLabels('${PriceRange.start.round()}',
                                  '${PriceRange.end.round()}'),
                            );
                          })),

                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            Expanded(
                                child: RaisedButton(onPressed:(){clearPriceRange();} ,child: Text(AS.Clear(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.ass_dark,)
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                                child: RaisedButton(onPressed:(){setPriceRange(MaxPrice, MaxPrice);} ,child: Text(AS.Apply(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.red,)
                            ),



                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }


  setPriceRange(double min, double max) {
    Navigator.of(context).pop(true);
    setState(() {


      _getDashboardItems(1);

    });
  }

  clearPriceRange() {
    Navigator.of(context).pop(true);
    setState(() {

      MinPrice=0.0;
      MaxPrice=200000.0;
      _getDashboardItems(1);
    });
  }

//Rating Start
  _showRating() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Stack(
            children: <Widget>[

              SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 50),
                  child: new Wrap(
                    children: <Widget>[
                      for (var i = 0; i < 6; i++)
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Text(i.toString()+AS.RatedItems(),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) =>
                                    Checkbox(
                                        value: getRating(i.toString()),
                                        checkColor: ColorPalette.red,
                                        activeColor: Colors.white,
                                        onChanged: (bool newValue) {
                                          setRatingSelection(i.toString(), newValue, setState);
                                        }),
                              ),

                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      IconButton(icon: Icon(Icons.clear,color: Colors.black87,size: 25,),onPressed: (){
                        Navigator.of(context).pop(true);
                      },),
                      Expanded(child:
                      Text("Ratings",style: TextStyle(color: Colors.black87,fontSize: 18),),),

                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Expanded(
                          child: RaisedButton(onPressed:(){setRateClear();} ,child: Text(AS.Clear(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.ass_dark,)
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                          child: RaisedButton(onPressed:(){setRatwApply();} ,child: Text(AS.Apply(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.red,)
                      ),



                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  getRating(var ratingid) {
    if (ratingSelected.contains(ratingid)) {
      return true;
    } else {
      return false;
    }
  }

  setRatingSelection(String ratingid, bool ratval,StateSetter state) {
    if (ratval) {
      if (ratingSelected.contains(ratingid)) {
      } else {
        state(() {
          ratingSelected.add(ratingid);
        });
      }
    } else {
      if (ratingSelected.contains(ratingid)) {
        state(() {
          ratingSelected.removeAt(ratingSelected.indexOf(ratingid));
        });
      } else {}
    }
  }

  setRateClear() {
    Navigator.of(context).pop(true);
    setState(() {
      ratingSelected.clear();
      ratingFinal="";
      _getDashboardItems(1);
    });
  }

  setRatwApply() {
    Navigator.of(context).pop(true);
    setState(() {
      for(int i=0;i<ratingSelected.length;i++){
        ratingFinal=ratingFinal+ratingSelected[i].toString()+",";
      }
      ratingFinal=ratingFinal.substring(0, ratingFinal.length - 1);
      debugPrint("aminity"+ratingFinal);
      PackageList.clear();
      _getDashboardItems(1);
    });
  }

  //Category Start
  _showCategory() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Stack(
            children: <Widget>[

              SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 50),
                  child: new Wrap(
                    children: <Widget>[
                      for (var i = 0; i < categoryList.length; i++)
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  categoryList[i]["cat_name"],
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) =>
                                    Checkbox(
                                        value: getCategory(categoryList[i]["cat_id"]),
                                        checkColor: ColorPalette.red,
                                        activeColor: Colors.white,
                                        onChanged: (bool newValue) {
                                          setCategorySelection(categoryList[i]["cat_id"], newValue, setState);
                                        }),
                              ),

                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      IconButton(icon: Icon(Icons.clear,color: Colors.black87,size: 25,),onPressed: (){
                        Navigator.of(context).pop(true);
                      },),
                      Expanded(child:
                      Text(AS.CategoryFilter(),style: TextStyle(color: Colors.black87,fontSize: 18),),),

                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Expanded(
                          child: RaisedButton(onPressed:(){setCategoryClear();} ,child: Text(AS.Clear(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.ass_dark,)
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                          child: RaisedButton(onPressed:(){setCategoryApply();} ,child: Text(AS.Apply(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.red,)
                      ),



                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
  getCategory(var catid) {
    if (categoryListSelect.contains(catid)) {
      return true;
    } else {
      return false;
    }
  }

  setCategorySelection(String catid, bool catval,StateSetter state) {
    if (catval) {
      if (categoryListSelect.contains(catid)) {
      } else {
        state(() {
          categoryListSelect.add(catid);
        });
      }
    } else {
      if (categoryListSelect.contains(catid)) {
        state(() {
          categoryListSelect.removeAt(categoryListSelect.indexOf(catid));
        });
      } else {}
    }
  }

  setCategoryClear() {
    Navigator.of(context).pop(true);
    setState(() {
      categoryListSelect.clear();
      categoryFinal="";
      _getDashboardItems(1);
    });
  }

  setCategoryApply() {
    Navigator.of(context).pop(true);
    setState(() {
      for(int i=0;i<categoryListSelect.length;i++){
        categoryFinal=categoryFinal+categoryListSelect[i].toString()+",";
      }
      categoryFinal=categoryFinal.substring(0, categoryFinal.length - 1);
      debugPrint("aminity"+categoryFinal);
      PackageList.clear();
      _getDashboardItems(1);
    });
  }

  //Tag Start
  _showTag() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Stack(
            children: <Widget>[

              SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 50),
                  child: new Wrap(
                    children: <Widget>[
                      for (var i = 0; i < tagList.length; i++)
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  tagList[i]["tag_name"],
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) =>
                                    Checkbox(
                                      checkColor: ColorPalette.red,
                                        activeColor: Colors.white,
                                        value: getTag(tagList[i]["tag_id"]),
                                        onChanged: (bool newValue) {
                                          setTagSelection(tagList[i]["tag_id"], newValue, setState);
                                        }),
                              ),

                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  width: MediaQuery.of(context).size.width,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Expanded(
                          child: RaisedButton(onPressed:(){setTagClear();} ,child: Text(AS.Clear(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.ass_dark,)
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                          child: RaisedButton(onPressed:(){setTagApply();} ,child: Text(AS.Apply(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.red,)
                      ),



                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      IconButton(icon: Icon(Icons.clear,color: Colors.black87,size: 25,),onPressed: (){
                        Navigator.of(context).pop(true);
                      },),
                      Expanded(child:
                      Text("Tag Filter",style: TextStyle(color: Colors.black87,fontSize: 18),),),

                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
  getTag(var tagid) {
    if (tagListSelected.contains(tagid)) {
      return true;
    } else {
      return false;
    }
  }

  setTagSelection(String tagid, bool tagval,StateSetter state) {
    if (tagval) {
      if (tagListSelected.contains(tagid)) {
      } else {
        state(() {
          tagListSelected.add(tagid);
        });
      }
    } else {
      if (tagListSelected.contains(tagid)) {
        state(() {
          tagListSelected.removeAt(tagListSelected.indexOf(tagid));
        });
      } else {}
    }
  }

  setTagClear() {
    Navigator.of(context).pop(true);
    setState(() {
      tagListSelected.clear();
      tagFinal="";
      _getDashboardItems(1);
    });
  }

  setTagApply() {
    Navigator.of(context).pop(true);
    setState(() {
      for(int i=0;i<tagListSelected.length;i++){
        tagFinal=tagFinal+tagListSelected[i].toString()+",";
      }
      tagFinal=tagFinal.substring(0, tagFinal.length - 1);
      debugPrint("tag"+tagFinal);
      PackageList.clear();
      _getDashboardItems(1);
    });
  }
  ShowImageEmpty() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      width: MediaQuery.of(context).size.width,
      child:  Column(
        children: <Widget>[
          SizedBox(height: 20,),
          Image.asset(
            "assets/images/nolikes.jpg",
            width: MediaQuery.of(context).size.width,
            height: 250,
          ),
          SizedBox(height: 20,),
          Text(AS.NoPackageFound(),
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
            child: Text(AS.ClearFilter(),
                style: TextStyle(
                  color: ColorPalette.TextColorRegular,
                  fontSize: 12.0,
                )),
            onPressed: () {

              setState(() {
                tagListSelected.clear();
                tagFinal="";
                categoryListSelect.clear();
                categoryFinal="";
                ratingSelected.clear();
                ratingFinal="";
                aminityListSelect.clear();
                aminityFinal="";
                MinPrice=0.0;
                City="";
                MaxPrice=200000.0;
                _getDashboardItems(1);

              });

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

  SetToday(){
    setState(() {
      DateTime dateToday = DateTime.now();
      TodayDate=""+dateToday.year.toString()+dateToday.month.toString()+dateToday.day.toString();
      SelectedDate="";
      TomorrowDate="";
      PackageList.clear();
      _getDashboardItems(1);
    });
  }

 CleartToday(){
    setState(() {
      TodayDate="";
      PackageList.clear();
      _getDashboardItems(1);
    });
  }

  SetTomorrow(){
    setState(() {
      DateTime dateToday = DateTime.now().add(Duration(days: 1));
      TomorrowDate=""+dateToday.year.toString()+"-"+dateToday.month.toString()+"-"+dateToday.day.toString();
      SelectedDate="";
      TomorrowDate="";
      PackageList.clear();
      _getDashboardItems(1);
    });
  }

  CleartTomorrow(){
    setState(() {
      TomorrowDate="";
      PackageList.clear();
      _getDashboardItems(1);
    });
  }

  SetPopular(){
    setState(() {
      Popular="1";
      PackageList.clear();
      _getDashboardItems(1);
    });
  }

  CleartPopular(){
    setState(() {
      Popular="";
      PackageList.clear();
      _getDashboardItems(1);
    });
  }

  DateTime selectedDateCalender = DateTime.now();
  Future<Null> SetDated(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDateCalender,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (picked != null && picked != selectedDateCalender)
      setState(() {
        selectedDateCalender = picked;
        String sday,smonth,syear,sbooked;

        if(selectedDateCalender.day<=9){
          sday="0"+selectedDateCalender.day.toString();
        }else{
          sday=selectedDateCalender.day.toString();
        }

        if(selectedDateCalender.month<=9){
          smonth="0"+selectedDateCalender.month.toString();
        }else{
          smonth=selectedDateCalender.month.toString();
        }
        syear=selectedDateCalender.year.toString();
        String BookDate = syear+"-"+smonth+"-"+sday;

        SelectedDate=BookDate;
        TomorrowDate="";
        TodayDate="";
        PackageList.clear();
        _getDashboardItems(1);
      });
  }

  CleartDated(){
    setState(() {
      SelectedDate="";
      PackageList.clear();
      _getDashboardItems(1);
    });
  }
}
