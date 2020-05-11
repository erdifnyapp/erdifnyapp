import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erdifny/screen/dashboard.dart';
import 'package:erdifny/utils/color_pallet.dart';

class SplashScreenSecond extends StatefulWidget {
  SplashScreenSecond({Key key}) : super(key: key);

  @override
  _SplashScreenSecondState createState() {
    return _SplashScreenSecondState();
  }
}

class _SplashScreenSecondState extends State<SplashScreenSecond> {

  Timer timer;

  _SplashScreenSecondState() {
    timer = new Timer(const Duration(milliseconds:4000), () {
      setState(() {

        Navigator.of(context).pop(true);

      });
    });
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: ColorPalette.splashback
        ),
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          "assets/images/logosec.gif",
          gaplessPlayback: true,

        ),
      ),
    );
  }
}
