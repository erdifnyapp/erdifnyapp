import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;


class VendorScreen extends StatefulWidget {
  VendorScreen({Key key}) : super(key: key);

  @override
  _VendorScreenState createState() {
    return _VendorScreenState();
  }
}

class _VendorScreenState extends State<VendorScreen> {

  String userEmail,userPasseword,userName,Vid;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController name = new TextEditingController();
  bool vname = false;

  TextEditingController lableName = new TextEditingController();
  bool vlableName = false;

  TextEditingController email = new TextEditingController();
  bool vemail = false;

  TextEditingController password = new TextEditingController();
  bool vpassword = false;
  bool showProgress;
  Map data;
  List getVendorDetail=[];

  _registerNow() async {
    setState(() {
      name.text.isEmpty ? vname = true : vname = false;
      lableName.text.isEmpty ? vlableName = true : vlableName = false;
      password.text.isEmpty ? vpassword = true : vpassword = false;
      email.text.isEmpty ? vemail = true : vemail = false;
    });

    if (vname || vlableName || vpassword || vemail) {
      SnakeBarUtils.Error(_scaffoldKey, "Please fill all");
    } else {

      setState(() {
        showProgress = true;
      });

      showProgress = false;
     debugPrint("Pass");

      String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';

      final response =
      await http.post(Urls.VendorRegister, headers: {HttpHeaders.acceptHeader:headers},body:  {
        "key": Const.APPKEY,
        "email": email.text,
        "password": password.text,
        "lableName": lableName.text,
        "name": name.text,
        "actype":ACtype.toString()
      });
      debugPrint(""+response.request.toString());
      data = json.decode(response.body);
      if (data["success"] == true) {


        setState(() {
          showProgress = false;
        });

        if(data["alert"]=="Added"){


          SharedStoreUtils.setValue(Const.VENDORID, data["vid"].toString());
          debugPrint("vid"+data["vid"].toString());
          SnakeBarUtils.Success(_scaffoldKey, "Success");
          Vid=data["vid"].toString();
          Navigator.pushReplacement( context, MyCustomRoute(builder: (context) => VendorScreen()));

        }else{
          SnakeBarUtils.Error(_scaffoldKey, "Something wrong");


        }



      }else{
        SnakeBarUtils.Error(_scaffoldKey, "Email Already exists");

      }
    }
  }

  _getVendorDetail() async {
    showProgress = true;
    Map<String, String> headers = {"Content-type": "application/json"};
    String jsonInput = '{"key": "' + Const.APPKEY +'","vid": "'+Vid + '"}';

    debugPrint("" + jsonInput);
    final response =
    await http.post(Urls.VendorView, headers: headers, body: jsonInput);
    data = json.decode(response.body);
    if (response.statusCode == 200) {
      showProgress = false;
      if (data["success"] == true) {
        setState(() {
          getVendorDetail = data["vendor"];
        });
      }
    }
  }

  int selectedRadio;
  String ACtype="Host";

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString(Const.PREF_USERNAME) ?? '';
      userPasseword = prefs.getString(Const.PREF_PASSWORD) ?? '';
      userName = prefs.getString(Const.PREF_NAME) ?? '';
      Vid = prefs.getString(Const.VENDORID) ?? '0';
      name.text=userName;
      password.text=userPasseword;
      email.text=userEmail;

      if(Vid!="0"){
        _getVendorDetail();
      }
    });


  }

  @override
  void initState() {
    super.initState();
    getSharedStore();
    selectedRadio = 0;
  }
  setSelectedRadio(int val) {
    setState(() {
      if(val==1){
        ACtype="Host";
      }else{
        if(val==2){
          ACtype="Vendor";
        }else{
          ACtype="Agent";
        }

      }
      selectedRadio = val;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(

        ),
        height: MediaQuery.of(context).size.height,
        child: _appBody(),
      ),
    );
  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(
      ),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(height: 60.0),
              SizedBox(height: 20.0),

              Image.asset('assets/images/vendoeimg.jpg',width: MediaQuery.of(context).size.width,height: 200,fit: BoxFit.cover,),
              if(getVendorDetail.length==0)formColumn(),
              if(getVendorDetail.length!=0)registerColumn(),


            ],
          ),
        ),
        TitleSearch(),
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
              icon: Icon(Icons.arrow_back),
              color: Colors.black38,
              iconSize: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                AS.Becomeavendor(),
                style: TextStyle(color: Colors.black, fontSize: 18.0),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  formColumn() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child:  Container(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 5),
        child: Column(

          children: <Widget>[
            Container(
              child:TextFormField(
                controller: name,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person,color: ColorPalette.black1,),
                  hintText: AS.YourName(),
                  labelText: AS.Name(),
                  errorText: vname ? 'Value Can\'t Be Empty' : null,
                  labelStyle: new TextStyle(color: ColorPalette.ass_dark),
                  fillColor: ColorPalette.white,
                  filled: true,
                  hintStyle: TextStyle(fontSize: 12, color: ColorPalette.ass),
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
            SizedBox(height: 15,),
            Container(
              child:TextFormField(
                controller: lableName,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.business,color: ColorPalette.black1,),
                  hintText: AS.CompanyOrIndividual(),
                  labelText: AS.LableName(),
                  errorText: vlableName ? 'Value Can\'t Be Empty' : null,
                  labelStyle: new TextStyle(color: ColorPalette.ass_dark),
                  fillColor: ColorPalette.white,
                  filled: true,
                  hintStyle: TextStyle(fontSize: 12, color: ColorPalette.ass),
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

            SizedBox(height: 15,),
            Container(
              child:TextFormField(
                controller: email,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email,color: ColorPalette.black1,),
                  hintText: AS.Email(),
                  labelText: AS.Email(),
                  errorText: vemail ? 'Value Can\'t Be Empty' : null,
                  labelStyle: new TextStyle(color: ColorPalette.ass_dark),
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
            SizedBox(height: 15,),
            Container(
              child:TextFormField(
                controller: password,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.dialpad,color: ColorPalette.black1,),
                  hintText: AS.Password(),
                  labelText: AS.YourPassword(),
                  errorText: vemail ? 'Value Can\'t Be Empty' : null,
                  labelStyle: new TextStyle(color: ColorPalette.ass_dark),
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
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Radio(
                  value: 1,
                  groupValue: selectedRadio,
                  activeColor: Colors.blue,
                  onChanged: (val) {
                    debugPrint("Radio $val");
                    setSelectedRadio(val);
                  },
                ),
                Text(
                  AS.Host(),
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Radio(
                  value: 2,
                  groupValue: selectedRadio,
                  activeColor: Colors.blue,
                  onChanged: (val) {
                    debugPrint("Radio $val");
                    setSelectedRadio(val);
                  },
                ),
                Text(
                  AS.Vendor(),
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Radio(
                  value: 2,
                  groupValue: selectedRadio,
                  activeColor: Colors.blue,
                  onChanged: (val) {
                    debugPrint("Radio $val");
                    setSelectedRadio(val);
                  },
                ),
                Text(
                  AS.Agent(),
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            RaisedButton(
              color: ColorPalette.red,
              textColor: ColorPalette.theamcolor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                child: Text(AS.RegisterNow(), style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.white)),
              ),
              onPressed: () async {
                _registerNow();
              },
            ),
            SizedBox(height: 20,),



          ],

        ),
      ),
    );
  }
  registerColumn() {
    return Container(padding: EdgeInsets.fromLTRB(10, 10, 10, 10) ,
    child:  Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 30, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[

          SizedBox(height: 15,),
          Text(
            AS.YourVendorDetail(),
            style: TextStyle(color: Colors.black, fontSize: 20.0),
            textAlign: TextAlign.left,
          ),
          Divider(),
          if(getVendorDetail[0]["admin_active"]=="0")Text(
            AS.YourProfileUnderVerify(),
            style: TextStyle(color: ColorPalette.red, fontSize: 15.0,fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          ListTile(
            leading:  Icon(Icons.email),
            title:  Text(AS.Email()),
            subtitle: Text(""+getVendorDetail[0]["admin_email"]),

          ),
          ListTile(
            leading:  Icon(Icons.business),
            title:  Text(AS.Company()),
            subtitle: Text(""+getVendorDetail[0]["admin_company"]),

          ),
          ListTile(
            leading:  Icon(Icons.nature_people),
            title:  Text(AS.CompanyOrIndividual()),
            subtitle: Text(""+getVendorDetail[0]["admin_type"]),
          ),
          if(getVendorDetail[0]["admin_active"]=="1")Text(
            "You can login with our admin panel with above login details. Please visit www.erdifny.com/API",
            style: TextStyle(color: Colors.green, fontSize: 15.0,fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),

        ],

      ),
    ),);
  }
}