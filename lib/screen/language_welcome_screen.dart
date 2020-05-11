import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/screen/welcomepage.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LanguageWelcomeScreen extends StatefulWidget {
  LanguageWelcomeScreen({Key key}) : super(key: key);

  @override
  _LanguageWelcomeScreenState createState() {
    return _LanguageWelcomeScreenState();
  }
}

class _LanguageWelcomeScreenState extends State<LanguageWelcomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showProgress = false;
  Map data;
  List ResponseData = [];
  String LanguageSelected;

  @override
  void initState() {
    super.initState();
    getSharedStore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Shared Preferences
  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      LanguageSelected = prefs.getString(Const.WELCOMEAppLanguage) ?? '';
    });

  }

  _setLanguage(int getval){
    setState(() {
      Const.AppLanguage=getval;
      debugPrint("selected lan$getval");
      SharedStoreUtils.setValue(Const.SETAPPLANGUAGE,getval.toString());
      SharedStoreUtils.setValue(Const.WELCOMEAppLanguage,"1");
      Navigator.pushReplacement(
          context, MyCustomRoute(builder: (context) => WelcomePage()));
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(fontFamily: "Calibra"),
      home: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          //   resizeToAvoidBottomPadding: false,

          body: Container(
            decoration:  BoxDecoration(
              color: ColorPalette.red,
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                _screenBody(),
                MyCircularProgressBar(showProgress),],
            ),
          ),
        ),
      ),
    );
  }

  _screenBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorPalette.red,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Image.asset("assets/images/logowhite.png",width: 100,height: 100,),
            SizedBox(height: 100,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 10,),
                Expanded(child: RaisedButton(
                  color: ColorPalette.white,
                  textColor: ColorPalette.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text("English",
                      style: TextStyle(
                          fontSize: 13.0,
                          textBaseline: TextBaseline.alphabetic)),
                  onPressed: () {
                    _setLanguage(0);
                  },
                ),),

                SizedBox(width: 15,),
                Expanded(
                  child: RaisedButton(

                    color: ColorPalette.white,
                    textColor: ColorPalette.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text("Arabic",
                        style: TextStyle(
                            fontSize: 13.0,
                            textBaseline: TextBaseline.alphabetic)),
                    onPressed: () {
                      _setLanguage(1);
                    },
                  ),
                ),
                SizedBox(width: 10,),

              ],
            )


          ],
        ),
      ),
    );
  }
}
