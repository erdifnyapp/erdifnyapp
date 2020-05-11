import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/screen/dashboard.dart';
import 'package:erdifny/screen/language_welcome_screen.dart';
import 'package:erdifny/screen/register_screen.dart';
import 'package:erdifny/screen/splashscreen.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:erdifny/screen/introscreen.dart';
import 'package:erdifny/screen/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:erdifny/utils/const.dart';



class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);

  @override
  _WelcomePageState createState() {
    return _WelcomePageState();
  }
}

class _WelcomePageState extends State<WelcomePage> {

  int _currentPage = 0;
  String welcomescreen="";
  String LanguageSelect="";

  bool showProgress = false;
  bool _isLoggedIn = false;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  _login() async{
    try{
      await _googleSignIn.signIn();
      setState(() {
        _isLoggedIn = true;
        debugPrint("profile-"+_googleSignIn.currentUser.photoUrl);
        debugPrint("profile-"+_googleSignIn.currentUser.displayName);
        _makeRegisterRequestWithImage(_googleSignIn.currentUser.email,_googleSignIn.currentUser.displayName,_googleSignIn.currentUser.photoUrl);
      });
    } catch (err){
      print(err);
      debugPrint("Already loged-");
    }
  }


  Map data;


  _makeRegisterRequestWithImage(String email,String name, String profile) async {

    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    final response =
    await http.post(Urls.sociallogin,headers: {HttpHeaders.acceptHeader:headers}, body:  {
      "key": Const.APPKEY,
      "email": email,
      "profile": profile,
      "name": name
    });
    debugPrint(""+response.request.toString());
    data = json.decode(response.body);
    if (data["success"] == true) {
      setState(() {
        showProgress = false;
      });

      debugPrint("IDDDD"+data["userid"]);
      SharedStoreUtils.setValue(Const.PREF_USERNAME, email);
      SharedStoreUtils.setValue(Const.PREF_PASSWORD, "000");
      SharedStoreUtils.setValue(Const.PREF_USERID, data["userid"]);

      Navigator.pushReplacement(
          context, MyCustomRoute(builder: (context) => SplashScreenPage()));


    }
  }


  void initState() {
    super.initState();
    getSharedStore();

  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      welcomescreen = prefs.getString(Const.WELCOMESCREEN) ?? '0';
      LanguageSelect = prefs.getString(Const.WELCOMEAppLanguage) ?? '0';
      debugPrint("LanguageSelect $LanguageSelect");
      if(LanguageSelect=="0"){
        Navigator.pushReplacement(
            context, MyCustomRoute(builder: (context) => LanguageWelcomeScreen()));
      }else{
        if(welcomescreen=="0"){
          Navigator.push(
              context, MyCustomRoute(builder: (context) => IntroScreen()));
        }
      }


    });

  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  MaterialApp(
      theme: ThemeData(fontFamily: "Calibra"),
      home: Scaffold(
        body:  Stack(
          children: <Widget>[

            contentSummary(),
            Positioned(bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset("assets/images/redbottom.png",width: MediaQuery.of(context).size.width,height: 100,fit: BoxFit.fill,),)

          ],
        ),

      ),
    );
  }

  contentSummary() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            Image.asset(
              "assets/images/logo.png",
              width: 120,
              height: 120,
            ),


            SizedBox(
              height: 100,
            ),
            RaisedButton(
              color: Colors.red,
              textColor: ColorPalette.red,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Container(
                width: 250,
                height: 50,
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text("CONNECT WITH GMAIL",
                      style: TextStyle(color: Colors.white,fontSize: 17 ),)
                  ],
                ),
              ),
              onPressed: () {
                _login();
              },
            ),
            SizedBox(
              height: 20,
            ),
            RaisedButton(
              color: Colors.indigo,
              textColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Container(
                width: 250,
                height: 50,
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    FaIcon(
                      FontAwesomeIcons.mailBulk,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text("CONNECT WITH EMAIL",
                      style:  TextStyle(color: Colors.white,fontSize: 17 ),)
                  ],
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    new MyCustomRoute(
                        builder: (context) =>  LoginPage()));
              },
            )
          ],
        )
      )
    );
  }
}