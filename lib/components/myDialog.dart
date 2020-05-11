import 'package:flutter/material.dart';
import 'package:erdifny/utils/color_pallet.dart';

class MyDialog extends StatelessWidget {

  final String title, description, buttonText;
  bool showProgress;
  MyDialog({
    @required this.showProgress,
    @required this.title,
    @required this.description,
    @required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: new Text(title),
      content: new Text(description),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        new FlatButton(
          child: new Text(buttonText),
          onPressed: () {
            showProgress=false;
          },
        ),
      ],
    );
  }



}
