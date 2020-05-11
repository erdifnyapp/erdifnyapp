import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/screen/aboutscreen.dart';
import 'package:erdifny/screen/bloglist.dart';
import 'package:erdifny/screen/languageselect.dart';
import 'package:erdifny/screen/splashscreen.dart';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/screen/vendorscreen.dart';
import 'package:erdifny/screen/walletscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:erdifny/components/url_open.dart';

import 'bookingscreen.dart';
import 'dashboard.dart';
import 'likelistscreen.dart';
import 'myprofile.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key key}) : super(key: key);

  @override
  _UserScreenState createState() {
    return _UserScreenState();
  }
}

class _UserScreenState extends State<UserScreen> {
  int currentTabIndex = 3;
  String userId, name, image, email;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool showProgress = false;

  @override
  void initState() {
    super.initState();
    getSharedStore();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString(Const.PREF_USERID) ?? '';
      name = prefs.getString(Const.PREF_NAME) ?? '';
      image = prefs.getString(Const.PREF_PROFILE_IMAGE) ?? '';
      email = prefs.getString(Const.PREF_USERNAME) ?? '';
    });
  }

  _clearSharedpreference() {
    SharedStoreUtils.clearValue();

    Navigator.pushAndRemoveUntil(
        context,
        MyCustomRoute(builder: (context) => SplashScreenPage()),
        ModalRoute.withName("/"));
  }



  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(fontFamily: "Calibra"),
      home: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: ColorPalette.red,
            ),
            child: _appBody(),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              ProfleView(),
              SizedBox(height: 5.0),
              MenuListing(),
            ],
          ),
        ),
        MyCircularProgressBar(showProgress),
      ]),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: ColorPalette.red,
      selectedItemColor: ColorPalette.white,
      unselectedItemColor: Colors.grey[200],
      unselectedIconTheme: IconThemeData(color: Colors.grey[300]),
      selectedIconTheme: IconThemeData(color: Colors.white,size: 27),
      onTap: _onBottomItemClicked,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.search), title: Text(AS.Explore())),
        BottomNavigationBarItem(
            icon: Icon(Icons.filter_hdr), title: Text(AS.Booking(),)),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), title: Text(AS.Saved())),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), title: Text(AS.You())),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: currentTabIndex,
    );
  }

  _onBottomItemClicked(int index) {
    setState(() {
      switch (index) {
        case 0:
          Navigator.of(context).pop(true);
          break;
        case 1:
          Navigator.pushReplacement(context,
              MyCustomRoute(builder: (context) => BookingScreen()));
          break;
        case 2:
          Navigator.pushReplacement(context,
              MyCustomRoute(builder: (context) => LikeListScreen()));
          break;
      }
    });
  }

  Future<bool> _onBackPressed() {
    Navigator.canPop(context);
  }

  ProfleView() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 3, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Erdifny",
                        maxLines: 1,
                        style: TextStyle(
                            color: ColorPalette.red,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Hello " + name,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(35.0),
                  child: FadeInImage(
                    image: NetworkImage(Urls.imageLocation + image),
                    placeholder: AssetImage(Urls.DummyImageBanner),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  MenuListing() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 3, 5, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          
          ListTile(
              leading: new Icon(Icons.person),
              title: new Text(AS.MyAccount()),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: () => {
                    Navigator.push(context,
                        MyCustomRoute(builder: (context) => MyProfile()))
                  }),

          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black38,
            height: 0.3,
          ),
          ListTile(
              leading: new Icon(Icons.account_balance_wallet),
              title: new Text(AS.Wallet()),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: () => {
                Navigator.push(context,
                    MyCustomRoute(builder: (context) => WalletScreen()))
              }),


          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black38,
            height: 0.3,
          ),
          ListTile(
              leading: new Icon(Icons.call),
              title: new Text(AS.ContactFaq()),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: () => {showHelpPop(context)
              }),


          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black38,
            height: 0.3,
          ),
          ListTile(
              leading: new Icon(Icons.language),
              title: new Text(AS.Language()),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: () => {Navigator.push( context, MyCustomRoute(builder: (context) => LanguageSelect()))}),


          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black38,
            height: 0.3,
          ),
          ListTile(
              leading: new Icon(Icons.info_outline),
              title: new Text(AS.Aboutus()),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: () => {Navigator.push( context, MyCustomRoute(builder: (context) => AboutScreen()))}),

          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black38,
            height: 0.3,
          ),



        ],
      ),
    );
  }

  HelpMenuList() {
    return Container(
      height: 230,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          ListTile(
              leading: FaIcon(FontAwesomeIcons.whatsapp),
              title: new Text(AS.WhatsappFaq()),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: () async {
                Navigator.of(context).pop(true);
                UrlOpenUtils.whatsapp(_scaffoldKey);
              }),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black38,
            height: 0.3,
          ),
          ListTile(
              leading: Icon(Icons.email,color: Colors.black38,),
              title: new Text(AS.EmailFaq()),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: ()  async{
                UrlOpenUtils.email(_scaffoldKey);

              }),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black38,
            height: 0.3,
          ),
          ListTile(
              leading: Icon(Icons.call,color: Colors.black38,),
              title: new Text(AS.ContactFaq()),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: () async {
                UrlOpenUtils.call(_scaffoldKey);
              }),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black38,
            height: 0.3,
          ),

          ListTile(
              leading: new Icon(Icons.info_outline),
              title: new Text(AS.Aboutus()),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 15,
              ),
              onTap: () => {
                Navigator.push(context,
                    MyCustomRoute(builder: (context) => AboutScreen()))
              }),

        ],
      ),
    );
  }

  showLogoutWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AS.Logout()),
          content: Text(
              AS.AreyouSureLogout()),
          actions: <Widget>[
            FlatButton(
              child: Text(AS.Cancel()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AS.Logout()),
              onPressed: () {
                _clearSharedpreference();
              },
            ),
          ],
        );
      },
    );
  }
  showHelpPop(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AS.Help()),
          content:  HelpMenuList(),

        );
      },
    );
  }
}
