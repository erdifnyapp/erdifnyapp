import 'package:flutter/material.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/screen/splashscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/utils/const.dart';

class LanguageSelect extends StatefulWidget {
  LanguageSelect({Key key}) : super(key: key);

  @override
  _LanguageSelectState createState() {
    return _LanguageSelectState();
  }
}

class _LanguageSelectState extends State<LanguageSelect> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _setLanguage(int getval){
    int getOldLang=Const.AppLanguage;
    if(getOldLang==getval){
      SnakeBarUtils.Error(_scaffoldKey, "Already Language selected");
    }else{
      setState(() {
        Const.AppLanguage=getval;
        SharedStoreUtils.setValue(Const.SETAPPLANGUAGE,getval.toString());
        Navigator.pushAndRemoveUntil( context,
            MyCustomRoute(builder: (context) => SplashScreenPage()),
            ModalRoute.withName("/"));
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: _appBody(),
      ),
    );
  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(height: 80.0),
              SizedBox(height: 20.0),
              ListTile(
                  leading: Icon(Icons.language),
                  title: Text("English"),
                  trailing: Visibility(
                    visible: checkEnglang(),
                    child: Icon(
                      Icons.check,
                      color: Colors.black38,
                      size: 20,
                    ),
                  ),
                  onTap: (){_setLanguage(0);}),
              Divider(),
              ListTile(
                  leading: Icon(Icons.language),
                  title: Text(AS.Arabic()),
                  trailing: Visibility(
                    visible: checkArabiclang(),
                    child: Icon(
                      Icons.check,
                      color: Colors.black38,
                      size: 20,
                    ),
                  ),
                  onTap: (){_setLanguage(1);}),
              Divider(),

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
                AS.Languages(),
                style: TextStyle(color: Colors.black, fontSize: 18.0),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  checkEnglang() {
    if(Const.AppLanguage==0){
      return true;
    }else{
      return false;
    }
  }

  checkArabiclang() {
    if(Const.AppLanguage==1){
      return true;
    }else{
      return false;
    }
  }
}