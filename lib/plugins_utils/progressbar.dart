import 'package:flutter/material.dart';
import 'package:erdifny/utils/color_pallet.dart';

class MyCircularProgressBar extends StatelessWidget {
  bool showProgress;
  MyCircularProgressBar(this.showProgress, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Visibility(
      visible: showProgress,
      child: Container(
        color: ColorPalette.black_opacity,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment(0, 0),
        child: Container(
          width: 100.0,
          height: 100.0,
          child: new Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Image.asset(
                    "assets/images/animationlogo.gif",
                  ))),
        ),
      ),
    );
  }
}
