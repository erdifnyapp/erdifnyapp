import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/screen/language_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/screen/dashboard.dart';
import 'package:erdifny/screen/introscreen.dart';
import 'package:erdifny/screen/splashscreensecond.dart';
import 'package:erdifny/screen/login_page.dart';
import 'package:erdifny/screen/register_screen.dart';
import 'package:erdifny/screen/welcomepage.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;

class SplashScreenPage extends StatefulWidget {
  SplashScreenPage({Key key}) : super(key: key);

  @override
  _SplashScreenPageState createState() {
    return _SplashScreenPageState();
  }
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var username, password, userid, name,SelecedAppLanguage;



  @override
  void initState() {
    super.initState();
    getSharedStore();
  }

  Map data;
  List userDate;

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString(Const.PREF_USERNAME) ?? '';
      password = prefs.getString(Const.PREF_PASSWORD) ?? '';
      userid = prefs.getString(Const.PREF_USERID) ?? '';
      name = prefs.getString(Const.PREF_NAME) ?? '';
      SelecedAppLanguage = prefs.getString(Const.SETAPPLANGUAGE) ?? '0';
      debugPrint("debugselect--"+SelecedAppLanguage);
      Const.AppLanguage= int.parse(SelecedAppLanguage);
    });

    userValidation();
  }

  void userValidation() {
    debugPrint("ssusername " + username);
    debugPrint("sspassword " + password);
    debugPrint("ssuserid " + userid);

    if (userid == "") {
      Navigator.pushReplacement(
          context, MyCustomRoute(builder: (context) => WelcomePage()));
    } else {
      _makePostRequest();
      debugPrint(" process");
    }
  }

  _makePostRequest() async {
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput = '{"key": "' +
        Const.APPKEY +
        '", "email": "' +
        username +
        '", "password": "' +
        password +
        '"}';
    debugPrint("sss" + jsonInput);
    final response =
        await http.post(Urls.validation, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);
    setState(() {
      userDate = data["jsonlist"];
      Const.USERDATA = data["jsonlist"];
    });


    if (data["success"] == true) {
      debugPrint("ddd" + userDate.toString());
      debugPrint("ddd" + userDate[0]["name"]);

      SharedStoreUtils.setValue(Const.PREF_USERID, userDate[0]["id"]);
      SharedStoreUtils.setValue(Const.PREF_USERNAME, userDate[0]["email"]);
      SharedStoreUtils.setValue(Const.PREF_PASSWORD, userDate[0]["password"]);
      SharedStoreUtils.setValue(Const.PREF_NAME, userDate[0]["name"]);
      SharedStoreUtils.setValue(Const.PREF_PHONE, userDate[0]["phone"]);
      SharedStoreUtils.setValue(Const.PREF_CREATED_DATE, userDate[0]["update_on"]);
      SharedStoreUtils.setValue(Const.PREF_PROFILE_IMAGE, userDate[0]["profile_image"]);
      SharedStoreUtils.setValue(Const.PREF_ACTIVE, userDate[0]["active"]);
      if (userDate[0]["active"] == "1") {

        Navigator.pushReplacement(
            context, MyCustomRoute(builder: (context) => Dashboard()));

        Navigator.push(
            context, MyCustomRoute(builder: (context) => SplashScreenSecond()));


      } else {
        SnakeBarUtils.Error(_scaffoldKey, "Your Profile Deactivated");
        Navigator.pushReplacement(
            context, MyCustomRoute(builder: (context) => WelcomePage()));
      }
    } else {
      Navigator.pushReplacement(
          context, MyCustomRoute(builder: (context) => WelcomePage()));
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
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: ColorPalette.splashback,
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(),
                  child: Text(
                    Const.AppName,
                    style: TextStyle(
                      color: ColorPalette.splashback,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 100,
                    height: 100,
                  ),
                ),
                SizedBox(height: 40),
                Center(
                    child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(ColorPalette.red)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
