import 'dart:convert';
import 'dart:io';
import 'package:erdifny/components/url_open.dart';
import 'package:flutter/cupertino.dart';
import 'package:erdifny/router/default_router.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/screen/bookingscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;

class PaymentConform extends StatefulWidget {
  PaymentConform({Key key}) : super(key: key);

  @override
  _PaymentConformState createState() {
    return _PaymentConformState();
  }
}

class _PaymentConformState extends State<PaymentConform> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String pid,
      userId,
      pname,
      psub,
      pimage,
      childmin,
      childmax,
      adultmin,
      adultmax,
      childminCount,
      childmaxCount,
      adultminCount,
      adultmaxCount,
      childprice,
      adultprice,
      vendorId,
      BookDate,
      VendorPercent,
      BookedDateInt;
  List<String> childNo, adultNo;
  double Total=0,FinalChildCost=0,FinalAdultCost=0;
  int FinalChildCount=0,FinalAdultCount=1;
  bool showProgress;
  Map data;
  TextEditingController wnote = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getSharedStore();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pid = prefs.getString(Const.PREF_PID) ?? '';
      userId = prefs.getString(Const.PREF_USERID) ?? '';
      pname = prefs.getString(Const.PREF_PNAME) ?? '';
      psub = prefs.getString(Const.PREF_PSUB) ?? '';
      pimage = prefs.getString(Const.PREF_PIMAGE) ?? '';
      vendorId = prefs.getString(Const.PREF_PVENDOR) ?? '';

      childmin = prefs.getString(Const.PCHILD_MIN) ?? '';
      childmax = prefs.getString(Const.PCHILD_MAX) ?? '';
      adultmin = prefs.getString(Const.PADULT_MIN) ?? '';
      adultmax = prefs.getString(Const.PADULT_MAX) ?? '';
      childminCount = prefs.getString(Const.PCHILD_MIN) ?? '';
      childmaxCount = prefs.getString(Const.PCHILD_MAX) ?? '';
      adultminCount = prefs.getString(Const.PADULT_MIN) ?? '';
      adultmaxCount = prefs.getString(Const.PADULT_MAX) ?? '';
      childprice = prefs.getString(Const.PCHILD_PRICE) ?? '';
      adultprice = prefs.getString(Const.PADULT_PRICE) ?? '';
      BookDate = prefs.getString(Const.PBOOK_DATE) ?? '';
      BookedDateInt = prefs.getString(Const.PBOOK_DATE_INT) ?? '';
      VendorPercent = prefs.getString(Const.PVENDOR_PERCENT) ?? '';

      childNo = [
        for (var i = int.parse(childmin); i <=int.parse(childmax); i += 1)
          i.toString()
      ];
      adultNo = [
        for (var i = int.parse(adultmin); i <= int.parse(adultmax); i += 1)
          i.toString()
      ];
      FinalChildCount = int.parse(childmin);
      FinalAdultCount = int.parse(adultmin);

      FinalChildCost=double.parse(childprice)*FinalChildCount;
      FinalAdultCost=double.parse(adultprice)*FinalAdultCount;
      Total=FinalChildCost+FinalAdultCost;
    });
  }

  _addBookingWallet() async {

    if(BookDate==null){
      SnakeBarUtils.Error(_scaffoldKey, "Please Select date");

    }else{
      showProgress=true;

      String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
      String jsonInput = '{"key": "' + Const.APPKEY +
          '","pid":"'+pid+
          '","uid":"'+userId+
          '","dated":"'+BookDate+
          '","datedint":"'+BookedDateInt+
          '","vendor":"'+vendorId+
          '","childno":"'+FinalChildCount.toString()+
          '","adultno":"'+FinalAdultCount.toString()+
          '","total_person":"'+(FinalChildCount+FinalAdultCount).toString()+
          '","pricechild":"'+FinalChildCost.toString()+
          '","priceadult":"'+FinalAdultCost.toString()+
          '","pname":"'+pname+
          '","note":"'+wnote.text+
          '","venderpercent":"'+VendorPercent+
          '","totalprice":"'+Total.toString()+ '"}';

      debugPrint("" + jsonInput);
      final response =
      await http.post(Urls.AddBookingWallet, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
      data = json.decode(response.body);
      if(response.statusCode==200){
        showProgress=false;
        if (data["success"] == true) {

          Navigator.pushReplacement(
              context, MyCustomRoute(builder: (context) => BookingScreen()));
          SnakeBarUtils.Error(_scaffoldKey, "Success - "+data["action"]);
        }else{
          SnakeBarUtils.Error(_scaffoldKey, " "+data["action"]);
        }
      }

    }


  }
  _addBookingPortal() async {

    if(BookDate==null){
      SnakeBarUtils.Error(_scaffoldKey, "Please Select date");

    }else{
      showProgress=true;

      Map<String, String> headers = {"Content-type": "application/json"};
      String jsonInput = '{"key": "' + Const.APPKEY +
          '","pid":"'+pid+
          '","uid":"'+userId+
          '","dated":"'+BookDate+
          '","datedint":"'+BookedDateInt+
          '","vendor":"'+vendorId+
          '","childno":"'+FinalChildCount.toString()+
          '","adultno":"'+FinalAdultCount.toString()+
          '","total_person":"'+(FinalChildCount+FinalAdultCount).toString()+
          '","pricechild":"'+FinalChildCost.toString()+
          '","priceadult":"'+FinalAdultCost.toString()+
          '","pname":"'+pname+
          '","note":"'+wnote.text+
          '","venderpercent":"'+VendorPercent+
          '","totalprice":"'+Total.toString()+ '"}';

      debugPrint("" + jsonInput);
      final response =
      await http.post(Urls.AddBookingPortal, headers: headers, body: jsonInput);
      data = json.decode(response.body);
      if(response.statusCode==200){
        showProgress=false;
        if (data["success"] == true) {

          Navigator.pushReplacement(
              context, MyCustomRoute(builder: (context) => BookingScreen()));
          SnakeBarUtils.Error(_scaffoldKey, "Success - "+data["action"]);
        }else{
          SnakeBarUtils.Error(_scaffoldKey, " "+data["action"]);
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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: ColorPalette.red,
        ),
        child: _appBody(),
      ),
    );
  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.whitmild,
      ),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(

            children: <Widget>[
              SizedBox(height: 60.0),
              BannerImage(context),
              SizedBox(height: 20.0),
              stagelist(),
              SizedBox(height: 20.0),
              PriceSummary(),
              SizedBox(height: 200.0),


            ],
          ),
        ),
        TitleSearch(),
        BottomPriceTag(),

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
        padding: EdgeInsets.fromLTRB(5, 35, 5, 5),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back,color: Colors.black,),
              color: Colors.black38,
              iconSize: 25,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                AS.ConformBooking(),
                style: TextStyle(color: Colors.black, fontSize: 18.0),
                textAlign: TextAlign.left,
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
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bgimg1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: <Widget>[
          FadeInImage(
            image: NetworkImage(Urls.imageLocation + pimage),
            placeholder: AssetImage(Urls.DummyImageBanner),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
            height: 350,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 350,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                  ColorPalette.black_opacity,
                  ColorPalette.black_hide
                ])),
          ),
          Positioned(
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  summary() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.person,
                  size: 20,
                  color: ColorPalette.TextColorTitle,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  AS.ADULT(),
                  style: TextStyle(
                    color: ColorPalette.TextColorTitle,
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.left,
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: DropdownButton<String>(
                hint: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("     " + FinalAdultCount.toString() + " "+AS.Members(),
                        style: TextStyle(
                          color: ColorPalette.TextColorRegular,
                          fontSize: 15.0,
                        )),
                  ),
                ),
                items: adultNo.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text("     " + value + " "+AS.Members()),
                  );
                }).toList(),
                onChanged: (String data) {
                  setState(() {
                    FinalAdultCount=int.parse(data);
                    FinalChildCost=double.parse(childprice)*FinalChildCount;
                    FinalAdultCost=double.parse(adultprice)*FinalAdultCount;
                    Total=FinalChildCost+FinalAdultCost;

                  });
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.child_friendly,
                  size: 20,
                  color: ColorPalette.TextColorTitle,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  AS.Child(),
                  style: TextStyle(
                    color: ColorPalette.TextColorTitle,
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.left,
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: DropdownButton<String>(
                hint: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("     " + FinalChildCount.toString() + " "+AS.Childrens(),
                        style: TextStyle(
                          color: ColorPalette.TextColorRegular,
                          fontSize: 15.0,
                        )),
                  ),
                ),
                items: childNo.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text("     " + value + " "+AS.Childrens()),
                  );
                }).toList(),
                onChanged: (String data) {
                  setState(() {
                    FinalChildCount=int.parse(data);
                    FinalChildCost=double.parse(childprice)*FinalChildCount;
                    FinalAdultCost=double.parse(adultprice)*FinalAdultCount;
                    Total=FinalChildCost+FinalAdultCost;
                  });
                },
              ),
            ),

            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    AS.AdultCost(),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    FinalAdultCount.toString()+"  x  "+FinalAdultCost.toString() + "  " + Const.CURRENCY,
                    style: TextStyle(
                      color: ColorPalette.TextColorTitle,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    AS.ChildCost(),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    FinalChildCount.toString()+"  x  "+FinalChildCost.toString() + "  " + Const.CURRENCY,
                    style: TextStyle(
                      color: ColorPalette.TextColorTitle,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 0.5,
              color: ColorPalette.ass,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    AS.TOTALCOST(),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    ""+Total.toString() + "  " + Const.CURRENCY,
                    style: TextStyle(
                        color: Colors.redAccent,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 90,
            ),
          ],
        ));
  }

  BottomPriceTag() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 2,
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          height: 60,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54, blurRadius: 5.0, offset: Offset(0.0, 1))
          ], color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  "   "+AS.TOTAL()+"  "+Total.toString() + "   " + Const.CURRENCY,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              RaisedButton(
                child: Text(AS.CheckOut()),
                onPressed: () {_showPaymentMethod();},
                color: ColorPalette.red,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                splashColor: Colors.grey,
              )
            ],
          ),
        ),
      ),
    );
  }

  stagelist() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            children: <Widget>[
              ListTile(title: Text(AS.NumberOfTravellers()),),
              Divider(),
              ChildCount(),
              AdultCount(),
              TripNote(),

            ],
          ),
        )
    );
  }

  ChildCount() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 5, 10),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[

        Icon(Icons.child_friendly,color: Colors.black,),
        SizedBox(width: 20,),
        Expanded(
          child: Text(AS.Child(),style: TextStyle(fontSize: 17),),
        ),

        IconButton(
          icon: Icon(Icons.remove_circle_outline,size: 30,color: Colors.grey,),
          onPressed: (){
            setState(() {
              if(FinalChildCount>int.parse(childminCount)){
                FinalChildCount=FinalChildCount-1;

              }

              FinalChildCost=double.parse(childprice)*FinalChildCount;
              FinalAdultCost=double.parse(adultprice)*FinalAdultCount;
              Total=FinalChildCost+FinalAdultCost;

            });
          },
        ),
        Text(FinalChildCount.toString(),style: TextStyle(fontSize: 15),),

        IconButton(
          icon: Icon(Icons.add_circle_outline,size: 30,color: Colors.grey),
          onPressed: (){
            setState(() {
              if(FinalChildCount<int.parse(childmaxCount)){
                FinalChildCount=FinalChildCount+1;

                FinalChildCost=double.parse(childprice)*FinalChildCount;
                FinalAdultCost=double.parse(adultprice)*FinalAdultCount;
                Total=FinalChildCost+FinalAdultCost;

              }


            });
          },
        ),


      ],
    ),);
  }
  AdultCount() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 5, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          Icon(Icons.person,color: Colors.black,),
          SizedBox(width: 20,),
          Expanded(
            child: Text(AS.Adult(),style: TextStyle(fontSize: 17),),
          ),

          IconButton(
            icon: Icon(Icons.remove_circle_outline,size: 30,color: Colors.grey,),
            onPressed: (){
              setState(() {
                if(FinalAdultCount>int.parse(adultminCount)){
                  FinalAdultCount=FinalAdultCount-1;

                  FinalChildCost=double.parse(childprice)*FinalChildCount;
                  FinalAdultCost=double.parse(adultprice)*FinalAdultCount;
                  Total=FinalChildCost+FinalAdultCost;
                }


              });
            },
          ),
          Text(FinalAdultCount.toString(),style: TextStyle(fontSize: 15),),

          IconButton(
            icon: Icon(Icons.add_circle_outline,size: 30,color: Colors.grey),
            onPressed: (){
              setState(() {
                if(FinalAdultCount<int.parse(adultmaxCount)){
                  FinalAdultCount=FinalAdultCount+1;

                  FinalChildCost=double.parse(childprice)*FinalChildCount;
                  FinalAdultCost=double.parse(adultprice)*FinalAdultCount;
                  Total=FinalChildCost+FinalAdultCost;
                }


              });
            },
          ),


        ],
      ),);
  }

  PriceSummary() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            children: <Widget>[
              ListTile(title: Text(AS.CostSummary()),),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.child_friendly,color: Colors.black,),
                    SizedBox(width: 20,),
                    Expanded(
                      flex: 1,
                      child: Text(
                        AS.ChildCost(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        FinalChildCount.toString()+"  x  "+FinalChildCost.toString() + "  " + Const.CURRENCY,
                        style: TextStyle(
                          color: ColorPalette.TextColorTitle,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.person,color: Colors.black,),
                    SizedBox(width: 20,),
                    Expanded(
                      flex: 1,
                      child: Text(
                        AS.AdultCost(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        FinalAdultCount.toString()+"  x  "+FinalAdultCost.toString() + "  " + Const.CURRENCY,
                        style: TextStyle(
                          color: ColorPalette.TextColorTitle,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),),
              Container(
                color: Colors.green.withOpacity(0.2),
                height: 50,
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        AS.TOTALCOST(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        ""+Total.toString() + "  " + Const.CURRENCY,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),),


            ],
          ),
        )
    );
  }

  _showPaymentMethod(){
    return  showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child:  Text(
                    AS.SelectPaymentMethod(),
                    style: TextStyle(
                      color: ColorPalette.black,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                Divider(),
                ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text(AS.FromWallet()),
                    onTap: () {
                      Navigator.of(context).pop();
                      _addBookingWallet();

                    }
                ),
                ListTile(
                  leading: Icon(Icons.monetization_on),
                  title:  Text(AS.FromPaymentPortal()),
                  onTap: ()  {
                    Navigator.of(context).pop();
                    _addBookingPortal();
                  },
                ),
              ],
            ),
          );
        }
    );
  }
  TripNote() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: TextField(
        controller: wnote,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.note_add,color: ColorPalette.black1,),
          hintText: AS.TripNote(),
          labelText: AS.AddNote(),
          labelStyle: new TextStyle(color: ColorPalette.black1),
          fillColor: ColorPalette.white,
          filled: true,
          hintStyle: TextStyle(fontSize: 12, color: ColorPalette.theamcolor_form_hint_color),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26, width: 1.0),
          ),
        ),
        style: new TextStyle(color: Colors.black),
      ),
    );
  }
}
