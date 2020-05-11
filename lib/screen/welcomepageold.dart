//import 'dart:async';
//import 'dart:convert';
//import 'dart:io';
//
//import 'package:erdifny/plugins_utils/shared_preference.dart';
//import 'package:erdifny/screen/dashboard.dart';
//import 'package:erdifny/screen/language_welcome_screen.dart';
//import 'package:erdifny/screen/splashscreen.dart';
//import 'package:erdifny/utils/urls.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_signin_button/button_builder.dart';
//import 'package:flutter_signin_button/button_list.dart';
//import 'package:flutter_signin_button/button_view.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:transparent_image/transparent_image.dart';
//import 'package:erdifny/screen/introscreen.dart';
//import 'package:erdifny/screen/login_page.dart';
//import 'package:http/http.dart' as http;
//import 'package:erdifny/utils/const.dart';
//
//
//
//class WelcomePage extends StatefulWidget {
//  WelcomePage({Key key}) : super(key: key);
//
//  @override
//  _WelcomePageState createState() {
//    return _WelcomePageState();
//  }
//}
//
//class _WelcomePageState extends State<WelcomePage> {
//
//  int _currentPage = 0;
//  String welcomescreen="";
//  String LanguageSelect="";
//  PageController _pageController = PageController(
//    initialPage: 0,
//  );
//  bool showProgress = false;
//  bool _isLoggedIn = false;
//  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
//
//  _login() async{
//    try{
//      await _googleSignIn.signIn();
//      setState(() {
//        _isLoggedIn = true;
//        debugPrint("profile-"+_googleSignIn.currentUser.photoUrl);
//        debugPrint("profile-"+_googleSignIn.currentUser.displayName);
//        _makeRegisterRequestWithImage(_googleSignIn.currentUser.email,_googleSignIn.currentUser.displayName,_googleSignIn.currentUser.photoUrl);
//      });
//    } catch (err){
//      print(err);
//      debugPrint("Already loged-");
//    }
//  }
//
//
//  Map data;
//
//
//  _makeRegisterRequestWithImage(String email,String name, String profile) async {
//
//    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
//    final response =
//    await http.post(Urls.sociallogin,headers: {HttpHeaders.acceptHeader:headers}, body:  {
//      "key": Const.APPKEY,
//      "email": email,
//      "profile": profile,
//      "name": name
//    });
//    debugPrint(""+response.request.toString());
//    data = json.decode(response.body);
//    if (data["success"] == true) {
//      setState(() {
//        showProgress = false;
//      });
//
//      debugPrint("IDDDD"+data["userid"]);
//      SharedStoreUtils.setValue(Const.PREF_USERNAME, email);
//      SharedStoreUtils.setValue(Const.PREF_PASSWORD, "000");
//      SharedStoreUtils.setValue(Const.PREF_USERID, data["userid"]);
//
//      Navigator.pushReplacement(
//          context, MyCustomRoute(builder: (context) => SplashScreenPage()));
//    }
//  }
//
//
//  void initState() {
//    super.initState();
//    getSharedStore();
//    Timer.periodic(Duration(seconds: 8), (Timer timer) {
//      if (_currentPage < 4) {
//        _currentPage++;
//      } else {
//        _currentPage = 3;
//      }
//
//      _pageController.animateToPage(
//        _currentPage,
//        duration: Duration(milliseconds: 200),
//        curve: Curves.fastOutSlowIn,
//      );
//    });
//  }
//
//  getSharedStore() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    setState(() {
//      welcomescreen = prefs.getString(Const.WELCOMESCREEN) ?? '0';
//      LanguageSelect = prefs.getString(Const.WELCOMEAppLanguage) ?? '0';
//      debugPrint("LanguageSelect $LanguageSelect");
//      if(LanguageSelect=="0"){
//        Navigator.pushReplacement(
//            context, MyCustomRoute(builder: (context) => LanguageWelcomeScreen()));
//      }else{
//        if(welcomescreen=="0"){
//          Navigator.push(
//              context, MyCustomRoute(builder: (context) => IntroScreen()));
//        }
//      }
//
//
//    });
//
//  }
//  @override
//  void dispose() {
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return  MaterialApp(
//      theme: ThemeData(fontFamily: "Calibra"),
//      home: Scaffold(
//        body:  Stack(
//          children: <Widget>[
//            backgroundImageSlide(),
//            Container(
//              height: MediaQuery.of(context).size.height,
//              width: MediaQuery.of(context).size.width,
//              color: Colors.black.withOpacity(0.2),
//            ),
//            contentSummary(),
//
//          ],
//        ),
//
//      ),
//    );
//  }
//
//  backgroundImageSlide() {
//    return Container(
//      height: MediaQuery.of(context).size.height,
//      width: MediaQuery.of(context).size.width,
//      decoration: BoxDecoration(
//        image: DecorationImage(
//          image: AssetImage('assets/images/wel1.jpg'),
//          fit: BoxFit.cover,
//        ),
//      ),
//      child: PageView(
//        controller: _pageController,
//        children: <Widget>[
//          Image.asset('assets/images/wel2.jpg',fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,),
//          Image.asset('assets/images/wel3.jpg',fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,),
//          Image.asset('assets/images/wel4.jpg',fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,),
//          Image.asset('assets/images/wel5.jpg',fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,),
//          Image.asset('assets/images/wel6.jpg',fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,),
//
//        ],
//      ),
//    );
//  }
//
//  contentSummary() {
//    return Container(
//      height: MediaQuery.of(context).size.height,
//      width: MediaQuery.of(context).size.width,
//      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.end,
//        crossAxisAlignment: CrossAxisAlignment.center,
//        children: <Widget>[
//
//          Expanded(
//            child:  Column(
//              mainAxisAlignment: MainAxisAlignment.start,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                SizedBox(height: 100,),
//              //  Image.asset('assets/images/logo.png',width: 100,height:100,),
//                Text(
//                  'ERDIFNY',
//                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 30,
//                    shadows: <Shadow>[
//                      Shadow(
//                        offset: Offset(2.0, 2.0),
//                        blurRadius: 5.0,
//                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
//                      ),
//                    ],
//                  ),
//                ),
//              ],
//            )
//          ),
//          SignInButtonBuilder(
//            text: 'Sign in with Google',
//            icon: FontAwesomeIcons.google,
//            onPressed: () {
//              _login();
//            },
//            backgroundColor: Colors.blue[700],
//          ),
//
//          SizedBox(height: 10,),
//
//          SignInButton(
//            Buttons.Email,
//            text: "Sign up with Email",
//            onPressed: () {
//              Navigator.pushReplacement(
//                  context, MyCustomRoute(builder: (context) => LoginPage()));
//            },
//          ),
//          SizedBox(height: 60,),
//        ],
//      ),
//    );
//  }
//}