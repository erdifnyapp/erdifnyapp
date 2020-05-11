import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:erdifny/components/url_open.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/plugins_utils/shared_preference.dart';
import 'package:erdifny/screen/productview.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:erdifny/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingView extends StatefulWidget {
  var getPid;
  BookingView({Key key,this.getPid}) : super(key: key);

  @override
  _BookingViewState createState() {
    return _BookingViewState(getPid);
  }
}

class _BookingViewState extends State<BookingView> {
  var pid,userId;
  _BookingViewState(this.pid);
  bool showProgress;
  Map data;
  List BookingDetail=[];
  List UserReview=[];
  TextEditingController name = new TextEditingController();
  bool vname = false;
  double rating=2;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _image;
  var imagepath;


  @override
  void initState() {
    super.initState();
    debugPrint("pid-" + pid);
    showProgress=false;
    getSharedStore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString(Const.PREF_USERID) ?? '';
    });
    _getBookingDetails();
  }

  _getBookingDetails() async {

    showProgress=true;
    Map<String, String> headers = {"Content-type": "application/json"};
    String jsonInput = '{"key": "' +
        Const.APPKEY +'",'
        '"bid":"'+pid+'",'+
        '"uid":"'+userId+
        '"}';

    debugPrint("" + jsonInput);
    final response =
    await http.post(Urls.BookingView, headers: headers, body: jsonInput);
    data = json.decode(response.body);
    if(response.statusCode==200){
      showProgress=false;
      if (data["success"] == true) {
        setState(() {

          BookingDetail = data["booking"];
          UserReview = data["rating"];
        });
      }
    }
  }

  _summitReview() async {
    showProgress=true;
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput = '{"key": "' +
        Const.APPKEY +'",'
        '"bid":"'+pid+'",'+
        '"rating":"'+rating.toString()+'",'+
        '"comment":"'+name.text+'",'+
        '"pid":"'+BookingDetail[0]["p_id"]+'",'+
        '"uid":"'+userId+
        '"}';

    debugPrint("" + jsonInput);
    final response =
    await http.post(Urls.AddReview, headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);
    if(response.statusCode==200){
      showProgress=false;
      if (data["success"] == true) {
        setState(() {

          BookingDetail = data["booking"];
          UserReview = data["rating"];
        });
      }
    }
  }


  _makeRegisterRequestWithImage() async {

    showProgress=true;

        final response = await http.post(Urls.AddReview, body:  {
          if(_image!=null)"image": base64Encode(_image.readAsBytesSync()),
          if(_image==null)"image": "no",
          "key": Const.APPKEY,
          "bid": pid,
          "rating": rating.toString(),
          "comment": name.text,
          "pid": BookingDetail[0]["p_id"],
          "uid": userId
        });
        debugPrint(""+response.request.toString());
        data = json.decode(response.body);
        if (data["success"] == true) {
          setState(() {
            showProgress = false;
            BookingDetail = data["booking"];
            UserReview = data["rating"];
          });

        }
      }




  _openProductView(var id, var name, var subtitle, var image) {
    SharedStoreUtils.setValue(Const.PREF_PID, id);
    SharedStoreUtils.setValue(Const.PREF_PNAME, name);
    SharedStoreUtils.setValue(Const.PREF_PSUB, subtitle);
    SharedStoreUtils.setValue(Const.PREF_PIMAGE, image);

    Navigator.push(
        context, MyCustomRoute(builder: (context) => ProductView()));
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
      body: Container(
        decoration: BoxDecoration(
        ),
        child: _appBody(),
      ),
    );
  }

  _appBody() {
    return Container(
      decoration: BoxDecoration(
      ),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(height: 60.0),
              if(BookingDetail.length!=0)BannerImage(context),


              SizedBox(height: 20.0),
              if(BookingDetail.length!=0)summary(),
              SizedBox(height: 10.0),
              if(UserReview.length!=0)showReview(),
              if(UserReview.length==0)writeReview(),

            ],
          ),
        ),
        TitleSearch(),
        MyCircularProgressBar(showProgress),

      ]),
    );
  }

  TitleSearch() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 35, 5, 5),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back,color: Colors.black,),
              color: Colors.black38,
              iconSize: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                AS.BookingDetail(),
                style: TextStyle(color: Colors.black, fontSize: 18.0),
                textAlign: TextAlign.left,
              ),
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.whatsapp,color: Colors.black.withOpacity(0.5),),
              onPressed: () async {
                UrlOpenUtils.whatsapp(_scaffoldKey);
              },
            ),
          ],
        ),
      ),
    );
  }
  BannerImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 250,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bgimg1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: <Widget>[
          FadeInImage(
            image: NetworkImage(Urls.imageLocation+BookingDetail[0]["p_image"] ),
            placeholder: AssetImage(Urls.DummyImageBanner),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
            height: 350,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 350,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      ColorPalette.black_opacity,
                      ColorPalette.black_hide
                    ])),
          ),
          Positioned(
            bottom: 5,
            left: 6,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              BookingDetail[0]["p_name"] ,
                              style: TextStyle(
                                color: ColorPalette.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              BookingDetail[0]["city_name"] ,
                              style: TextStyle(
                                color: ColorPalette.white,
                                fontSize: 15.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  summary() {
    return Container(
      color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
        margin: EdgeInsets.fromLTRB(10, 1, 10, 10),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector( onTap: () {
    _openProductView(
    BookingDetail[0]["p_id"],
        BookingDetail[0]["p_name"],
        BookingDetail[0]["p_sub"],
        BookingDetail[0]["p_image"]);

              },
              child: ListTile(title: Text(BookingDetail[0]["p_name"]),
                  subtitle: Text("Click to view",style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),)), ),


            Divider(),
            ListTile(

              title: Text(AS.TotalPerson()+"  "),
              subtitle: Text(BookingDetail[0]["total_person"]+"  "+AS.Person()),
              leading: Icon(Icons.people),
            ),
            ListTile(
              title: Text(AS.PricePaidforAdult()+" "),
              subtitle: Text(BookingDetail[0]["adult_no"]+" x "+BookingDetail[0]["adultprice"]+" = "+Const.CURRENCY+" "+BookingDetail[0]["priceadult"]),
              leading: Icon(Icons.person),
            ),
            ListTile(
              title: Text(AS.PricePaidforChild()),
              subtitle: Text(BookingDetail[0]["child_no"]+" x  "+BookingDetail[0]["childprice"]+" = "+Const.CURRENCY+" "+BookingDetail[0]["pricechild"]),
              leading: Icon(Icons.child_friendly),
            ),
            ListTile(
              title: Text(AS.TotalPaid()),
              subtitle: Text(BookingDetail[0]["totalprice"]+" "+Const.CURRENCY+"    "+AS.Paid()),
              leading: Icon(Icons.account_balance_wallet),
            ),
            ListTile(
              title: Text(AS.TripDate()),
              subtitle: Text(BookingDetail[0]["booked_dated"]),
              leading: Icon(Icons.date_range),
            ),
            ListTile(
              title: Text(AS.Duration()),
              subtitle: Text(BookingDetail[0]["days"]),
              leading: Icon(Icons.alarm),
            ),
            ListTile(
              title: Text(AS.MeetingPoint()),
              subtitle: Text(BookingDetail[0]["meeting"]),
              leading: Icon(Icons.location_on),
            ),
            ListTile(
              title: Text(AS.BookingNote()),
              subtitle: Text(BookingDetail[0]["booking_note"].toString()),
              leading: Icon(Icons.near_me),
            ),
          ],
        ));
  }
  showReview() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
        margin: EdgeInsets.fromLTRB(10, 1, 10, 30),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(title: Text(AS.YourReview())),
            if(UserReview[0]["r_image"]!="")FadeInImage(
              image: NetworkImage(Urls.imageLocation + UserReview[0]["r_image"]),
              placeholder: AssetImage(Urls.DummyImageBanner),
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.fill,
            ),

            Divider(),
            ListTile(

              title: Text(UserReview[0]["r_commend"]+""),
              subtitle: Container(
                padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: RatingStars(UserReview[0]["r_stars"]),),
              leading: Icon(Icons.mode_edit),
            ),


            

          ],
        ));
  }
  writeReview() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
        margin: EdgeInsets.fromLTRB(10, 1, 10, 30),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(title: Text(AS.WriteYourReview())),

            Divider(),
            Text( AS.Scaleyourrating(),
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
            ),
            Slider(
              value: rating,
              divisions: 5,
              min: 0,
              max: 5,
              label: "$rating",
              onChanged: (newRating){
                setState(() {
                  rating=newRating;
                });
              },
            ),

            SizedBox(
              height: 70,
              child:TextFormField(
                controller: name,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: AS.YourReview(),
                  labelText: AS.Review(),
                  errorText: vname ? 'Value Can\'t Be Empty' : null,
                  labelStyle: TextStyle(color: ColorPalette.black1),
                  fillColor: ColorPalette.theamcolor_form_back,
                  hintStyle: TextStyle(fontSize: 12, color: ColorPalette.black1),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorPalette.red, width: 1.0),
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                    onTap: (){
                      _showPop();
                    },
                    child: ImageShow()
                ),
                Expanded(child: SizedBox(width: 10,),),
                RaisedButton(
                  color: ColorPalette.red,
                  textColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Text(AS.Summit(),
                      style: TextStyle(
                          fontSize: 13.0,
                          textBaseline: TextBaseline.alphabetic)),
                  onPressed: () {
                    _makeRegisterRequestWithImage();
                  },
                ),


              ],
            ),







          ],
        ));
  }
  RatingStars(var ratings) {
    switch (ratings) {
      case "0":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
          ],
        );
        break;

      case "1":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
          ],
        );
        break;

      case "2":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
          ],
        );
        break;

      case "3":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
          ],
        );
        break;

      case "4":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 15,
            ),
          ],
        );
        break;

      case "5":
        return Row(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 15,
            ),
          ],
        );
        break;
    }
    ;
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
        borderRadius: BorderRadius.circular(10.0),
        child: Image.asset(
          'assets/images/add.png',
          width: 200.0,
          height: 120.0,
          fit: BoxFit.contain,
        ),
      );
    }else{
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.file(
          _image,
          width: 200.0,
          height: 120.0,
          fit: BoxFit.contain,
        ),
      );
    }
  }


}