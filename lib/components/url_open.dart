import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/utils/const.dart';
import 'package:flutter/src/material/scaffold.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlOpenUtils{

  static whatsapp(GlobalKey<ScaffoldState> scaffoldKey)async{
    var whatsappUrl ="whatsapp://send?phone=+"+Const.WHATSAPPNUMBER;
    await canLaunch(whatsappUrl)? launch(whatsappUrl):SnakeBarUtils.Error(scaffoldKey, "Whatsapp not installed");
  }

  static email(GlobalKey<ScaffoldState> scaffoldKey)async{
    var url = 'mailto:'+Const.SHAREEMAIL+'?subject=HelloErdifny&body=MyMail';
    await canLaunch(url)? launch(url):SnakeBarUtils.Error(scaffoldKey, "Email cannot send");
  }

  static openurl(GlobalKey<ScaffoldState> scaffoldKey,String geturl)async{
    var url = ''+geturl;
    await canLaunch(url)? launch(url):SnakeBarUtils.Error(scaffoldKey, "Something Error");
  }

  static call(GlobalKey<ScaffoldState> scaffoldKey)async{
    launch("tel://"+Const.WHATSAPPNUMBER);
  }
}