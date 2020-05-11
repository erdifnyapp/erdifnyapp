import 'dart:convert';
import 'package:erdifny/router/default_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/plugins_utils/snakebar.dart';
import 'package:erdifny/screen/login_page.dart';
import 'package:erdifny/screen/splashscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController username = new TextEditingController();
  bool vusername = false;
  TextEditingController password = new TextEditingController();
  bool vpassword = false;
  TextEditingController name = new TextEditingController();
  bool vname = false;
  TextEditingController cpassword = new TextEditingController();
  bool vcpassword = false;
  TextEditingController phone= new TextEditingController();
  bool vphone = false;
  bool showProgress;
  File _image;
  var imagepath;


  @override
  void initState() {
    super.initState();
    showProgress = false;
  }

  Map data;


  _makeRegisterRequestWithImage() async {
    setState(() {
      name.text.isEmpty ? vname = true : vname = false;
      username.text.isEmpty ? vusername = true : vusername = false;
      password.text.isEmpty ? vpassword = true : vpassword = false;
      cpassword.text.isEmpty ? vcpassword = true : vcpassword = false;
      phone.text.isEmpty ? vphone = true : vphone = false;
    });

    if (vname || vusername || vpassword || vcpassword) {
      SnakeBarUtils.Error(_scaffoldKey, "Haii");
    } else {
      if (password.text == cpassword.text) {
        setState(() {
          showProgress = true;
        });

     //   String base64Image = base64Encode(_image.readAsBytesSync());
        String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';

        final response =
        await http.post(Urls.register,headers: {HttpHeaders.acceptHeader:headers}, body:  {
          if(_image!=null)"image": base64Encode(_image.readAsBytesSync()),
          if(_image==null)"image": "no",
          "key": Const.APPKEY,
          "email": username.text,
          "password": password.text,
          "phone": phone.text,
          "name": name.text
        });
        debugPrint(""+response.request.toString());
        data = json.decode(response.body);
        if (data["success"] == true) {
          setState(() {
            showProgress = false;
          });
          if(data["userid"]=="0"){
            SnakeBarUtils.Error(_scaffoldKey, "Email Already exists");

          }else{
            SnakeBarUtils.Error(_scaffoldKey, "Account Created");
            SharedStoreUtils.setValue(Const.PREF_USERNAME, username.text);
            SharedStoreUtils.setValue(Const.PREF_PASSWORD, password.text);
            SharedStoreUtils.setValue(Const.PREF_USERID, data["userid"]);

            Navigator.pushReplacement(
                context, MyCustomRoute(builder: (context) => SplashScreenPage()));


          }


        }
      } else {
        SnakeBarUtils.Error(_scaffoldKey, "not match");

      }
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
      print(_image.lengthSync());
    });

  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,

      body: Container(
      decoration: BoxDecoration(
        color: ColorPalette.theamcolor,
      ),
      child: Stack(
        children: <Widget>[

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/back1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Image.asset(
                    "assets/images/logowhite.png",
                    width: 110,
                    height: 110,
                  ),
                  SizedBox(height: 60,),
                ],
              )
            ),
          ),


          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(

              child: Column(
                children: <Widget>[
                  const SizedBox(height: 220.0),
                  Container(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(40.0),
                          topRight: const Radius.circular(40.0),
                        ),
                      image: DecorationImage(
                        image: AssetImage('assets/images/pattern.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 10.0),
                        Text("ERDIFNY SIGNUP",  style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                        const SizedBox(height: 5.0),
                        Container(
                          height: 2,
                          width: 100,
                          color: ColorPalette.red,
                        ),
                        const SizedBox(height: 30.0),

                        SizedBox(
                          height: 55,
                          child:TextFormField(
                            controller: name,
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
                            style: new TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        SizedBox(
                          height: 55,
                          child:TextField(
                            controller: username,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email,color: ColorPalette.black1,),
                              hintText: AS.Youremail(),
                              labelText: AS.Email(),
                              errorText: vusername ? 'Value Can\'t Be Empty' : null,
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
                            style: new TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        SizedBox(
                          height: 55,
                          child:TextField(
                            controller: phone,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone_iphone,color: ColorPalette.black1,),
                              hintText: AS.YourPhone(),
                              labelText: AS.Phone(),
                              errorText: vusername ? 'Value Can\'t Be Empty' : null,
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
                            style: new TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        SizedBox(
                          height: 55,
                          child:TextField(
                            controller: password,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.dialpad,color: ColorPalette.black1,),
                              hintText: AS.YourPassword(),
                              labelText: AS.Password(),
                              errorText: vpassword ? 'Value Can\'t Be Empty' : null,
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
                            style: new TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        SizedBox(
                          height: 55,
                          child:TextField(
                            controller: cpassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.dialpad,color: ColorPalette.black1,),
                              hintText: AS.RetypePassword(),
                              labelText: AS.ConformPassword(),
                              errorText: vcpassword ? 'Value Can\'t Be Empty' : null,
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
                            style: new TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        GestureDetector(
                            onTap: (){
                              _showPop();
                            },
                            child: ImageShow()
                        ),
                        const SizedBox(height: 25.0),
                        SizedBox(
                          width: 200,
                          height: 40,
                          child: RaisedButton(
                            color: ColorPalette.red,
                            textColor: ColorPalette.theamcolor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(AS.RegisterNow(), style: TextStyle(
                                fontSize: 13.0,
                            color: Colors.white)),
                            onPressed: () {
                              _makeRegisterRequestWithImage();
                            },
                          ),
                        ),
                        const SizedBox(height: 5.0),

                        SizedBox(width: 200,
                          child: RaisedButton(
                            color: ColorPalette.black_hide,
                            textColor: ColorPalette.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            child: Text(AS.Login(),
                                style: TextStyle(
                                    fontSize: 13.0,
                                    textBaseline: TextBaseline.alphabetic)),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  new MyCustomRoute(
                                      builder: (context) => new LoginPage()));
                            },
                          ),),


                      ],
                    ),
                  )


                ],
              ),
            ),
          ),

          MyCircularProgressBar(showProgress),
        ],
      ),

    ),
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

  ImageShow() {
    if(_image==null){
      return ClipRRect(
        borderRadius: BorderRadius.circular(55.0),
        child: Image.asset(
          'assets/images/avat.png',
          width: 110.0,
          height: 110.0,
          fit: BoxFit.fill,
        ),
      );
    }else{
      return ClipRRect(
        borderRadius: BorderRadius.circular(55.0),
        child: Image.file(
          _image,
          width: 110.0,
          height: 110.0,
          fit: BoxFit.fill,
        ),
      );
    }
  }
}
