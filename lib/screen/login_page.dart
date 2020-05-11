import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:flutter/material.dart';
import 'package:erdifny/components/alart_demo.dart';
import 'package:erdifny/components/myDialog.dart';
import 'package:erdifny/plugins_utils/SharedPreferences.dart';
import 'package:erdifny/plugins_utils/alartmessage.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/screen/register_screen.dart';
import 'package:erdifny/screen/splashscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:http/http.dart' as http;
import 'package:erdifny/utils/urls.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController username = new TextEditingController();
  bool vusername = false;
  TextEditingController password = new TextEditingController();
  bool vpassword = false;

  bool showProgress;
  @override
  void initState() {
    super.initState();
    showProgress = false;
  }

  Map data;
  List userDate;
  _makePostRequest() async {
    setState(() {

      username.text.isEmpty ? vusername = true : vusername = false;
      password.text.isEmpty ? vpassword = true : vpassword = false;

    });

    if (vusername || vpassword) {
      SnakeBarUtils.Error(_scaffoldKey, "Please fill all details");
    } else {
      setState(() {
        showProgress = true;
      });
      String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
      String jsonInput = '{"key": "' +
          Const.APPKEY +
          '", "email": "' +
          username.text +
          '", "password": "' +
          password.text +
          '"}';

      final response =
          await http.post(Urls.login, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
      data = json.decode(response.body);
      setState(() {
        userDate = data["jsonlist"];

        showProgress = false;
      });
      if (data["success"] == true) {

        SharedStoreUtils.setValue(Const.PREF_USERNAME, username.text);
        SharedStoreUtils.setValue(Const.PREF_PASSWORD, password.text);
        SharedStoreUtils.setValue(Const.PREF_USERID, userDate[0]["id"]);


        Navigator.pushReplacement(
            context, MyCustomRoute(builder: (context) => SplashScreenPage()));


      } else {

        SnakeBarUtils.Error(_scaffoldKey, "Username or Password not matched");

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
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: true,
      body: Container(
        decoration: BoxDecoration(
          color: ColorPalette.theamcolor,
        ),
        child: Stack(
          children: <Widget>[

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bgimg1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Image.asset(
                        "assets/images/logowhite.png",
                        width: 110,
                        height: 110,
                      ),
                      SizedBox(height: 100,),
                    ],
                  )
              ),
            ),


            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(

                child:Column(
                  children: <Widget>[
                    const SizedBox(height: 260.0),
                    Container(
                 //     height: MediaQuery.of(context).size.height-260,
                      padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(40.0),
                          topRight: const Radius.circular(40.0),
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/images/pattern.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 10.0),
                          Text("ERDIFNY LOGIN",  style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,),
                          const SizedBox(height: 5.0),
                          Container(
                            height: 2,
                            width: 100,
                            color: ColorPalette.red,
                          ),
                          const SizedBox(height: 30.0),

                          SizedBox(
                            height: 55,
                            child:TextField(
                              controller: username,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email,color: ColorPalette.black1,),
                                hintText: AS.Youremail(),
                                labelText: AS.Email(),
                                errorText: vusername ? 'Value Can\'t Be Empty' : null,
                                labelStyle: new TextStyle(color: ColorPalette.black1),
                                fillColor: ColorPalette.theamcolor_form_back,
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
                          const SizedBox(height: 25.0),
                          SizedBox(
                            height: 55,
                            child:TextField(
                              controller: password,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.dialpad,color: ColorPalette.black1,),
                                hintText: AS.YourPassword(),
                                labelText: AS.Password(),
                                errorText: vpassword ? 'Value Can\'t Be Empty' : null,
                                labelStyle: new TextStyle(color: ColorPalette.black1),
                                fillColor: ColorPalette.theamcolor_form_back,
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
                          const SizedBox(height: 25.0),

                          SizedBox(
                            width: 200,
                            height: 40,
                            child: RaisedButton(
                              color: ColorPalette.red,
                              textColor: ColorPalette.theamcolor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(AS.LoginNow(), style: TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.white)),
                              onPressed: () {
                                _makePostRequest();
                              },
                            ),
                          ),
                          const SizedBox(height: 5.0),

                          SizedBox(width: 200,
                            child: RaisedButton(
                              color: ColorPalette.black_hide,
                              textColor: ColorPalette.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              child: Text(AS.Register(),
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      textBaseline: TextBaseline.alphabetic)),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    new MyCustomRoute(
                                        builder: (context) => new RegisterScreen()));
                              },
                            ),),


                        ],
                      ),
                    )


                  ],
                ),
              ),
            ),

            MyCircularProgressBar(showProgress),
          ],
        ),

      ),
    );
  }



}
