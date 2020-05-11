import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:http/http.dart' as http;


class WalletScreen extends StatefulWidget {
  WalletScreen({Key key}) : super(key: key);



  @override
  _WalletScreenState createState() {
    return _WalletScreenState();
  }
}

class _WalletScreenState extends State<WalletScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  bool showProgress = false;
  List WalletList=[];
  String Balance="";
  Map data;
  var userId,Name,Email;
  TextEditingController wamount = new TextEditingController();
  bool vamount = false;

  @override
  void initState() {
    super.initState();
    getSharedStore();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString(Const.PREF_USERID) ?? '';
    });
    _getDashboardItems();
  }

  _getDashboardItems() async {
    // debugPrint("userid-"+ userId);
    showProgress=true;
    setState(() {
    });
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput =
        '{"key": "' + Const.APPKEY +'","uid":"'+ userId.toString()  + '"}';
    debugPrint("URL--" + jsonInput);
    final response =
    await http.post(Urls.Wallet,headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);

    if (data["success"] == true) {
      setState(() {
        showProgress=false;
        WalletList=data["wallet"];
        Balance=data["balance"];
      });
    }

    //   debugPrint("City--"+CityList.toString());
  }

  void _addMoney() async {
    Navigator.pop(context, true);
    setState(() {

      wamount.text.isEmpty ? vamount = true : vamount = false;

    });
    if (vamount) {
      SnakeBarUtils.Error(_scaffoldKey, AS.Pleasefillalldetails());
    } else {
      setState(() {
        showProgress = true;
      });
      Map<String, String> headers = {"Content-type": "application/json","Access-Control-Allow-Origin":"*"};
      String jsonInput = '{"key": "' +
          Const.APPKEY +
          '", "uid": "' +userId +
          '", "reason": "' +"Wallet Amount Added" +
          '", "amount": "' + wamount.text +
          '"}';

      final response =
      await http.post(Urls.AddWallet, headers: headers, body: jsonInput);
      data = json.decode(response.body);

      if (data["success"] == true) {
        setState(() {
          showProgress=false;
          Navigator.pushReplacement(
              context, MyCustomRoute(builder: (context) => WalletScreen()));
        });

      } else {

        SnakeBarUtils.Error(_scaffoldKey, "Something Wrong");

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
          key: _scaffoldKey,
          resizeToAvoidBottomPadding: false,
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: ColorPalette.red,
            ),
            child: _appBody(),
          ),
        ),
      ),
    );
  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.homebg,
      ),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[

              SizedBox(height: 50,),
              banner(),
              SizedBox(height: 10,),
              BookingListing(),

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
      height: 60,
      decoration: BoxDecoration(
        color: ColorPalette.red,
      ),
      child: Padding(
          padding: EdgeInsets.fromLTRB(5, 3, 5, 5),
          child: Column(
            children: <Widget>[
              Row(

                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back,color: Colors.white,),
                    iconSize: 20,
                    hoverColor: ColorPalette.black_opacity_overy,
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      AS.MyWallet(),
                      style: TextStyle(color: Colors.white, fontSize: 20.0),

                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 30,)



                ],
              ),
            ],
          )
      ),
    );
  }

  banner() {
    return Container(
      child: Material(
          elevation: 1,
          child:Container(
            color: ColorPalette.red,
            height: 180,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(10, 5, 10, 2),
            child: Column(
              children: <Widget>[

                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Icon(
                    Icons.account_balance_wallet,color: Colors.white,size: 40,
                  ),
                  SizedBox(width: 10,),
                  Text(
                    Balance,
                    style: TextStyle(color: Colors.white, fontSize: 50),),
                    Text(
                      "    AED",
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),)
                ],),
                Text(
                  AS.YourErdifnyWalletBalance(),
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),),
                SizedBox(height: 10,),

                OutlineButton(
                  child: Text(AS.AddBalance(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      )),
                  onPressed: () {
                    _addBalance();
                  },
                  borderSide: BorderSide(
                    color: Colors.white,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                  hoverColor: Colors.white,
                  focusColor:Colors.white,
                )
              ],
            ),
          )
      ),
    );
  }

  BookingListing() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        //+1 for progressbar
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: WalletList.length,
        itemBuilder: (BuildContext context, int index) {
          if(WalletList[index]["type"]=="0"){
            return decrimentCard(index);
          }else{
            return incrementCard(index);

          }

        },
        controller: _scrollController,
      ),
    );

  }

  incrementCard(int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child:  Container(
        color: Colors.white,
        height: 70,
        padding: EdgeInsets.fromLTRB(10, 5, 20, 5) ,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.trending_up,color: Colors.green,size: 40,
            ),
            SizedBox(width: 15,),
            Expanded(
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    WalletList[index]["reason"],
                    style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 15),maxLines: 1,),
                  Text(
                    WalletList[index]["dated"],
                    style: TextStyle(color: Colors.grey, fontSize: 10),maxLines: 1,),
                ],
              ),
            ),
            SizedBox(width: 10,),
            Text(
                WalletList[index]["amount"]+" AED",
              style: TextStyle(color: Colors.green, fontSize: 15),),
          ],
        ),
      ),
    );
  }

  decrimentCard(int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child:  Container(
        color: Colors.white,
        height: 70,
        padding: EdgeInsets.fromLTRB(10, 5, 20, 5) ,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.trending_down,color: ColorPalette.red,size: 40,
            ),
            SizedBox(width: 15,),
            Expanded(
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    WalletList[index]["reason"],
                    style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 15),maxLines: 1,),
                  Text(
                    WalletList[index]["dated"],
                    style: TextStyle(color: Colors.grey, fontSize: 10),maxLines: 1,),
                ],
              ),
            ),
            SizedBox(width: 10,),
            Text(
              WalletList[index]["amount"]+" AED",
              style: TextStyle(color: ColorPalette.red, fontSize: 15),),
          ],
        ),
      ),
    );
  }

  _addBalance() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 250,
              alignment: Alignment.center,
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: TextField(
                      controller: wamount,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_balance_wallet,color: ColorPalette.black1,),
                        hintText: AS.Howmuchamount(),
                        labelText: AS.Amount(),
                        errorText: vamount ? 'Value Can\'t Be Empty' : null,
                        labelStyle: new TextStyle(color: ColorPalette.black1),
                        fillColor: ColorPalette.white,
                        filled: true,
                        hintStyle: TextStyle(fontSize: 12, color: ColorPalette.theamcolor_form_hint_color),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black26, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ColorPalette.red, width: 1.0),
                        ),
                      ),
                      style: new TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child:RaisedButton(onPressed:(){

                      _addMoney();
                    } ,child: Text(AS.AddBalance(),style: TextStyle(fontSize: 12,color: Colors.white),),color: ColorPalette.red,)
                    ,
                  )

                ],
              ),
            ),
          );
        });
  }


}