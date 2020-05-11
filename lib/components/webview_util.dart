import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:erdifny/utils/urls.dart';

class WebviewUtils extends StatelessWidget {
  WebviewUtils({ @required this.bid});
  YoutubePlayerController _controller;
  String bid;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return  WebView(
        key: Key("webview1"),
        debuggingEnabled: true,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: Urls.WebviewforNews+"?id="+bid);
  }
}
