import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:http/http.dart' as http;
import 'package:erdifny/utils/urls.dart';

class HelpPage extends StatefulWidget {
  HelpPage({Key key}) : super(key: key);

  @override
  _HelpPageState createState() {
    return _HelpPageState();
  }
}

class _HelpPageState extends State<HelpPage> {
  bool showProgress;
  Map data;
  var HelpFile;

  @override
  void initState() {
    super.initState();
    _getBookingDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getBookingDetails() async {
    showProgress = true;
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput = '{"key": "' + Const.APPKEY + '"}';

    debugPrint("" + jsonInput);
    final response =
        await http.post(Urls.HelpPage,headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);
    if (response.statusCode == 200) {
      showProgress = false;
      if (data["success"] == true) {
        setState(() {
          HelpFile = data["help"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(),
        child: _appBody(),
      ),
    );
  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(height: 60.0),
              SizedBox(height: 20.0),
              if (HelpFile != null)
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    HelpFile.toString(),
                    style: TextStyle(
                      color: ColorPalette.black,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                )
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
                AS.Help(),
                style: TextStyle(color: Colors.black, fontSize: 18.0),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
