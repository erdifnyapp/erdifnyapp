import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/utils/const.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);

  @override
  _IntroScreenState createState() {
    return _IntroScreenState();
  }
}

class _IntroScreenState extends State<IntroScreen> {
  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SharedStoreUtils.setValue(Const.WELCOMESCREEN,"1");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _globalKey,
      body: OverBoard(
        pages: pages,
        showBullets: true,
        skipCallback: () {
          Navigator.of(context).pop(true);
          

        },
        finishCallback: () {
          Navigator.of(context).pop(true);

        },
      ),
    );
  }

  final pages = [
    PageModel(
        color: ColorPalette.introbg,
        imageAssetPath: 'assets/images/p1.png',
        title: '',
        body: AS.ReadytoexploreUAE(),
        doAnimateImage: true),
    PageModel(
        color: ColorPalette.introbg,
        imageAssetPath: 'assets/images/p2.png',
        title: '',
        body: AS.SelectaDate(),
        doAnimateImage: true),

    PageModel(
        color: ColorPalette.introbg,
        imageAssetPath: 'assets/images/p3.png',
        title: '',
        body: AS.Enjoyourholiday(),
        doAnimateImage: true),

  ];



}