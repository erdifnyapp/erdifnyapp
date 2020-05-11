import 'dart:convert';
import 'package:erdifny/router/default_router.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/screen/myprofile.dart';
import 'package:erdifny/screen/splashscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  EditProfile({Key key}) : super(key: key);

  @override
  _EditProfileState createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController yourname = new TextEditingController();
  bool vname = false;
  TextEditingController yourphone= new TextEditingController();
  bool vphone = false;

  var name,email,image,phone,userid;
  bool showProgress;

  Map data;
  File _image;
  var imagepath;

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
      yourname.text=name;
      yourphone.text=phone;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _makeRegisterRequestWithImage() async {
    setState(() {
      yourname.text.isEmpty ? vname = true : vname = false;
      yourphone.text.isEmpty ? vphone = true : vphone = false;
    });

    if (vname || vphone ) {
      SnakeBarUtils.Error(_scaffoldKey, AS.Pleasefillalldetails());
    } else {
      setState(() {
        showProgress = true;
      });

      String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';

      final response =
      await http.post(Urls.UpdateUser,headers: {HttpHeaders.acceptHeader:headers}, body:  {
        "key": Const.APPKEY,
        "phone": yourphone.text,
        "uid":userid,
        "name": yourname.text
      });
      debugPrint(""+response.request.toString());
      data = json.decode(response.body);
      if (data["success"] == true) {
        setState(() {
          showProgress = false;
          SharedStoreUtils.setValue(Const.PREF_NAME, yourname.text);
          SharedStoreUtils.setValue(Const.PREF_PHONE, yourphone.text);

          Navigator.pushReplacement(
              context, MyCustomRoute(builder: (context) => MyProfile()));
        });



      }
    }
  }

  _UpdateImage() async {

    debugPrint("uid"+userid);
    setState(() {
      showProgress = true;
    });

    final response =
    await http.post(Urls.UpdateImage, body:  {
      if(_image!=null)"image": base64Encode(_image.readAsBytesSync()),
      "key": Const.APPKEY,
      "uid": userid
    });
    debugPrint(""+response.request.toString());
    data = json.decode(response.body);
    if (data["success"] == true) {
      setState(() {
        showProgress = false;
      });

      SnakeBarUtils.Success(_scaffoldKey, "Haii");

      Navigator.pushAndRemoveUntil( context,
          MyCustomRoute(builder: (context) => SplashScreenPage()),
          ModalRoute.withName("/"));
    }
  }




  getImageFile(ImageSource source) async {

    var image = await ImagePicker.pickImage(source: source, imageQuality: 80);

    //Cropping the image
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Erdifny',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Erdifny',
        minimumAspectRatio: 1.0,
      ),
      maxWidth: 512,
      maxHeight: 512,
    );






    setState(() {
      _image = croppedFile;
      imagepath=croppedFile;
      _UpdateImage();
      print(_image.lengthSync());
    });

  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
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
              child: GestureDetector(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: FadeInImage(
                      image: NetworkImage(Urls.imageLocation + image),
                      placeholder: AssetImage(Urls.DummyImageBanner),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                ),
                onTap: (){
                  _showPop();
                },
              ),
              margin: EdgeInsets.only(left: 16.0),
            ),
            Positioned(top: 60,
              left: 70,
              child: IconButton(
                icon: Icon(Icons.mode_edit,color: Colors.black87,size: 20,),
              ),),


          ],
        )


    );
  }
  summary() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        width: MediaQuery.of(context).size.width,
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            children: <Widget>[
              ListTile(title: Text(AS.Userinformation()),),
              Divider(),
              SizedBox(
                height: 50,
                child: TextFormField(
                  controller: yourname,
                  keyboardType: TextInputType.text,

                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person,color: ColorPalette.black1,),
                    hintText: AS.YourName(),
                    labelText: AS.Name(),
                    errorText: vname ? 'Value Can\'t Be Empty' : null,
                    labelStyle: new TextStyle(color: ColorPalette.black1),
                    fillColor: ColorPalette.theamcolor_form_back,
                    filled: true,
                    hintStyle: TextStyle(fontSize: 12, color: ColorPalette.theamcolor_form_hint_color),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black26, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorPalette.red, width: 1.0),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 20,),
              SizedBox(height: 50,
              child: TextFormField(
                controller: yourphone,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone,color: ColorPalette.black1,),
                  hintText: AS.Phone(),
                  labelText: AS.Phone(),
                  errorText: vname ? 'Value Can\'t Be Empty' : null,
                  labelStyle: new TextStyle(color: ColorPalette.black1),
                  fillColor: ColorPalette.theamcolor_form_back,
                  filled: true,
                  hintStyle: TextStyle(fontSize: 12, color: ColorPalette.theamcolor_form_hint_color),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black26, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorPalette.red, width: 1.0),
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),),

              SizedBox(height: 10,),

              ListTile(
                  trailing: Icon(Icons.save),
                  title: Text(AS.Save()),

                  onTap: () => {
                    _makeRegisterRequestWithImage()
                  }),

            ],
          ),
        )


    );
  }


  _showPop(){
    return  showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text(AS.Camera()),
                    onTap: () => {
                      getImageFile(ImageSource.camera),
                      Navigator.pop(context),


                    }
                ),
                new ListTile(
                  leading: new Icon(Icons.image),
                  title: new Text(AS.Gallery()),
                  onTap: () => {getImageFile(ImageSource.gallery),
                    Navigator.pop(context),},
                ),
              ],
            ),
          );
        }
    );
  }
}