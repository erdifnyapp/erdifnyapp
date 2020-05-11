import 'package:flutter/material.dart';

class ImageFullScreen extends StatelessWidget {
  final String imgurl;
  ImageFullScreen({Key key,@required this.imgurl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(imgurl),
            fit: BoxFit.cover
        ) ,
      ),
    );;
  }
}
