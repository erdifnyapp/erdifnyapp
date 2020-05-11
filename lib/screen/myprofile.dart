import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/screen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:erdifny/screen/editprofile.dart';
import 'package:erdifny/router/default_router.dart';


class MyProfile extends StatefulWidget {
  MyProfile({Key key}) : super(key: key);

  @override
  _MyProfileState createState() {
    return _MyProfileState();
  }
}

class _MyProfileState extends State<MyProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var name,email,image,phone,userid;
  bool showProgress;

  @override
  void initState() {
    super.initState();
    showProgress=false;

    getSharedStore();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString(Const.PREF_NAME) ?? '';
      userid = prefs.getString(Const.PREF_USERID) ?? '';
      email = prefs.getString(Const.PREF_USERNAME) ?? '';
      image = prefs.getString(Const.PREF_PROFILE_IMAGE) ?? '';
      phone = prefs.getString(Const.PREF_PHONE) ?? '';
    });
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


  _clearSharedpreference() {
    SharedStoreUtils.clearValue();
    Navigator.pushAndRemoveUntil(
        context,
        MyCustomRoute(builder: (context) => SplashScreenPage()),
        ModalRoute.withName("/"));
  }


  _openEdit(){
    Navigator.pushReplacement( context, MyCustomRoute(builder: (context) => EditProfile()));
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,

      resizeToAvoidBottomPadding: false,
      body:  Container(
        decoration: BoxDecoration(
          color: ColorPalette.white,
        ),
        child: _appBody(),
      ),
    );
  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.whitmild,
      ),
      child: Stack(children: <Widget>[
        BannerImage(context),

        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[

              SizedBox(height: 160,),
              usersmall(),
              summary(),
              menuList(),
              SizedBox(height: 60,),



            ],
          ),
        ),
        GoBackButton(),
        MyCircularProgressBar(showProgress),
        //  TitleSearch(),
      ]),
    );
  }

  GoBackButton() {
    return Positioned(
      left: 7,
      top: 30,
      child: Container(
        height: 40,
        width: 40,

        child: Center(
          child: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white,),
            iconSize: 30,
            hoverColor: ColorPalette.black_opacity_overy,
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  BannerImage(BuildContext context) {
    return Stack(
      children: <Widget>[

        Container(
          width: MediaQuery.of(context).size.width,
          height: 240,
          decoration: BoxDecoration(

            image: DecorationImage(
              image: AssetImage('assets/images/bgimg1.jpg'),
              fit: BoxFit.cover,

            )
            ,
          ),
          child: FadeInImage(
            image: NetworkImage(Urls.imageLocation +image),
            placeholder: AssetImage(Urls.DummyImageBanner),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 250,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 240,
          decoration: BoxDecoration(
              color: ColorPalette.black_opacity_overy
          ),
        ),

      ],
    );
  }

  usersmall() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      width: MediaQuery.of(context).size.width,
      height: 130,
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.only(top: 16.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 106.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(name, style: Theme.of(context).textTheme.title,),
                      SizedBox(height: 5,),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15.0,),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "ED-"+userid,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12.0,),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Container(
            height: 100,
            width: 90,
            child:   ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: FadeInImage(
                  image: NetworkImage(Urls.imageLocation + image),
                  placeholder: AssetImage(Urls.DummyImageBanner),
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                )
            ),
            margin: EdgeInsets.only(left: 16.0),
          ),

        ],
      )


    );
  }
  summary() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            children: <Widget>[
              ListTile(title: Text(AS.Userinformation()),),
              Divider(),
              ListTile(

                title: Text(AS.Name()),
                subtitle: Text(name),
                leading: Icon(Icons.person),
              ),
              ListTile(
                title: Text(AS.Phone()),
                subtitle: Text(phone),
                leading: Icon(Icons.phone),
              ),
              ListTile(
                title: Text(AS.Email()),
                subtitle: Text(email),
                leading: Icon(Icons.email),
              ),
              ListTile(
                title: Text("Erdifny ID"),
                subtitle: Text("ER"+userid),
                leading: Icon(Icons.near_me),
              ),
              ListTile(
                title: Text(AS.EditProfile()),
                trailing: Icon(Icons.edit),

                onTap: (){

                  Navigator.push( context, MyCustomRoute(builder: (context) => EditProfile()));


                },
              ),
            ],
          ),
        )
    );
  }
  menuList() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            children: <Widget>[

              ListTile(

                title: Text(AS.Logout()),
                leading: Icon(Icons.power_settings_new),
                onTap: (){
                  showLogoutWarning(context);
                },
              ),

            ],
          ),
        )
    );
  }

  _displaySnackBar() {
    final snackBar = SnackBar(content: Text('Are you talkin\' to me?'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

}