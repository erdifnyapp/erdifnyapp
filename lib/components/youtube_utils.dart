import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeUtils extends StatelessWidget {

  YoutubeUtils({
    @required this.youtubeurl
  });

  YoutubePlayerController _controller;
  String youtubeurl;
  bool _isPlayerReady = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _controller = YoutubePlayerController(
      initialVideoId: youtubeurl.toString(),
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),

    );
    return YoutubePlayer(
      controller: _controller,
      progressIndicatorColor: Colors.blueAccent,

      onReady: () {
        _isPlayerReady = true;
      },

    );
  }
}
