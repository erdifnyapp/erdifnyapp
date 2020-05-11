import 'package:erdifny/components/url_open.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/screen/splashscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erdifny/utils/color_pallet.dart';

class AboutScreen extends StatefulWidget {
  AboutScreen({Key key}) : super(key: key);

  @override
  _AboutScreenState createState() {
    return _AboutScreenState();
  }
}

class _AboutScreenState extends State<AboutScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  showLogoutWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AS.Logout()),
          content: Text(
              AS.AreyouSureLogout()),
          actions: <Widget>[
            FlatButton(
              child: Text(AS.Cancel()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AS.Logout()),
              onPressed: () {
                _clearSharedpreference();
              },
            ),
          ],
        );
      },
    );
  }


  _clearSharedpreference() {
    SharedStoreUtils.clearValue();
    Navigator.pushAndRemoveUntil(
        context,
        MyCustomRoute(builder: (context) => SplashScreenPage()),
        ModalRoute.withName("/"));
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
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: _appBody(),
          ),
        ),
      ),
    );
  }

  _appBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(children: <Widget>[

        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              TitleSearch(),
              SizedBox(height: 50,),
              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 130,
                  height: 130,
                ),
              ),

              SizedBox(height: 5,),
              Center(
                child: Text("Version : 2.0", style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.0,),),
              ),
              SizedBox(height: 40,),
              Center(
                child: Text("UAE - Business Bay\nThe Exchange Tower", style: TextStyle(
                  color: Colors.black87,

                  fontSize: 15.0,),textAlign: TextAlign.center,),

              ),
              SizedBox(height: 5,),
              Center(
                child: Text("erdifny@gmail.com", style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12.0,),textAlign: TextAlign.center,),
              ),
              SizedBox(height: 60,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Text("PRIVACY POLICY", style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,),textAlign: TextAlign.center,),
                    onTap: (){
                      UrlOpenUtils.openurl(_scaffoldKey, "http://139.59.15.12/app-privacy.html");
                    },
                  ),
                  Container(width: 1,height: 20,color: Colors.grey,margin: EdgeInsets.fromLTRB(10, 0, 10, 0),),
                  GestureDetector(
                    child: Text("TERMS OF USE", style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,),textAlign: TextAlign.center,),
                    onTap: (){
                      UrlOpenUtils.openurl(_scaffoldKey, "http://139.59.15.12/app-terms.html");
                    },
                  ),

                ],
              ),
              SizedBox(height: 50,),
              Center(
                child:  GestureDetector(
                  child: Text("Logout", style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,),textAlign: TextAlign.center,),
                  onTap: (){
                    showLogoutWarning(context);
                  },
                ),
              )





            ],
          ),
        ),

        //  TitleSearch(),
      ]),
    );
  }
  TitleSearch() {
    return Container(
      height: 60,

      child: Padding(
          padding: EdgeInsets.fromLTRB(5, 3, 5, 5),
          child: Column(
            children: <Widget>[
              Row(

                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back,color: Colors.black,),
                    iconSize: 20,
                    hoverColor: ColorPalette.black_opacity_overy,
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  SizedBox(width: 30,)



                ],
              ),
            ],
          )
      ),
    );
  }
}