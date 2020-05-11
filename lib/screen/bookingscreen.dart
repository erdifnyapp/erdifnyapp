import 'dart:convert';
import 'dart:io';
import 'package:erdifny/router/default_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_card/ticket_card.dart';
import 'package:erdifny/plugins_utils/Fluttertoast.dart';
import 'package:erdifny/plugins_utils/progressbar.dart';
import 'package:erdifny/screen/productlistscreen.dart';
import 'package:erdifny/screen/bookingview.dart';
import 'package:erdifny/screen/userscreen.dart';
import 'package:erdifny/utils/appstr.dart';
import 'package:erdifny/utils/color_pallet.dart';
import 'package:erdifny/utils/const.dart';
import 'package:http/http.dart' as http;
import 'package:erdifny/utils/urls.dart';


import 'dashboard.dart';
import 'likelistscreen.dart';

class BookingScreen extends StatefulWidget {
  BookingScreen({Key key}) : super(key: key);

  @override
  _BookingScreenState createState() {
    return _BookingScreenState();
  }
}

class _BookingScreenState extends State<BookingScreen> {
  int currentTabIndex = 1;
  bool showProgress=false;
  ScrollController _scrollController = new ScrollController();
  List UpcomingList=[],PastList=[];
  Map data;
  var userId,Name,Email;
  int responseStatus=0;

  @override
  void initState() {
    super.initState();
    getSharedStore();

  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString(Const.PREF_USERID) ?? '';
      Name = prefs.getString(Const.PREF_NAME) ?? '';
      Email = prefs.getString(Const.PREF_USERNAME) ?? '';
      _getBookingItems();
    });
  }

  _getBookingItems() async {

    showProgress=true;
    setState(() {

      responseStatus=0;
    });
    String headers = '{"Content-type": "application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"application/json"}';
    String jsonInput =
        '{"key": "' + Const.APPKEY +'","uid":"'+ userId.toString()  + '"}';
    debugPrint("URL--" + jsonInput);
    final response =
    await http.post(Urls.ViewBooking,headers: {HttpHeaders.acceptHeader:headers}, body: jsonInput);
    data = json.decode(response.body);


    if (data["success"] == true) {
      setState(() {
        showProgress=false;
        UpcomingList=data["upcoming"];
        PastList=data["previous"];
        responseStatus=200;

      });
    }

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
        child:  Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: ColorPalette.white,
            ),
            child: _appBody(),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    )

    ;
  }


  _appBody() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(height: 50),
              if (PastList.length==0 && UpcomingList.length==0 && responseStatus==200) ShowImageEmpty(),
              if(UpcomingList!=null)TicketUpcoming(),
              if (PastList != null) TicketOld(),


              SizedBox(height: 110.0),
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
      height: 50,
      decoration: BoxDecoration(
        color: ColorPalette.white,
      ),
      child: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10,),
              Row(

                children: <Widget>[

                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(
                      AS.MyBooking(),
                      style: TextStyle(color: ColorPalette.red, fontSize: 22.0,fontWeight: FontWeight.bold),

                      textAlign: TextAlign.left,
                    ),
                  ),

                ],
              ),
            ],
          )
      ),
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
      switch(index){
        case 0:
          Navigator.of(context).pop(true);
          break;

        case 2:
          Navigator.pushReplacement(
              context, MyCustomRoute(builder: (context) => LikeListScreen()));
          break;
        case 3:
          Navigator.pushReplacement(
              context, MyCustomRoute(builder: (context) => UserScreen()));
          break;
      }
    });
  }

  Future<bool> _onBackPressed() {
    Navigator.canPop(context);
  }




  TicketUpcoming() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        //+1 for progressbar
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: UpcomingList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 250,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push( context, MyCustomRoute(builder: (context) => BookingView(getPid: UpcomingList[index]["b_id"],)));
              },
              child:   TicketCard(
                decoration: TicketDecoration(
                    shadow: [TicketShadow(color: Colors.black, elevation: 2)],
                    border: TicketBorder(
                        color: Colors.green,
                        width: 0.1,
                        style: TicketBorderStyle.dotted
                    )
                ),
                lineFromTop: 165,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  color: ColorPalette.ticketUpcoming,
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Expanded(
                            child: Text(AS.BookingID(),style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 13),),
                          ),
                          Text("#ER0"+UpcomingList[index]["b_id"],style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 13),),
                        ],
                      ),
                      Divider(color: ColorPalette.red,),
                      SizedBox(height: 5,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Expanded(
                            child: Text(AS.Name(),style: TextStyle(color: Colors.black,fontSize: 15),),
                          ),
                          Text(Name.toString(),style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 3,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Expanded(
                            child: Text(AS.Email(),style: TextStyle(color: Colors.black,fontSize: 15),),
                          ),
                          Text(Email,style: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Divider(),
                      SizedBox(height: 3,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.filter_hdr,color: ColorPalette.red,size: 20,),
                          Expanded(
                            child: Text("  "+UpcomingList[index]["p_name"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15),),
                          ),

                        ],
                      ),
                      SizedBox(height: 3,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Icon(Icons.arrow_right,color: ColorPalette.red,size: 20,),
                          Expanded(
                            child: Text("  "+UpcomingList[index]["total_person"]+" "+AS.Person(),style: TextStyle(color: Colors.black,fontSize: 13),),
                          ),
                          Icon(Icons.arrow_right,color: ColorPalette.red,size: 20,),
                          Expanded(
                            child: Text(UpcomingList[index]["days"],style: TextStyle(color: Colors.black,fontSize: 13),),
                          ),
                          Icon(Icons.arrow_right,color: ColorPalette.red,size: 20,),
                          Expanded(
                            child: Text("On "+UpcomingList[index]["booked_dated"],style: TextStyle(color: Colors.black,fontSize: 12),),
                          ),

                        ],
                      ),
                      SizedBox(height: 35,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(AS.Total()+" : ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15),),
                          Expanded(
                            child: Text(UpcomingList[index]["totalprice"]+" AED ",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 15),),
                          ),
                          Container(
                            color: Colors.green,
                            height: 20,
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            alignment: Alignment.center,
                            child: Text(AS.Upcoming(),style: TextStyle(color: Colors.white,fontSize: 10),)  ,
                          ),


                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        controller: _scrollController,
      ),
    );

  }
  ShowImageEmpty() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      width: MediaQuery.of(context).size.width,
      child:  Column(
        children: <Widget>[
          SizedBox(height: 20,),
          Image.asset(
            "assets/images/travel.jpg",
            width: MediaQuery.of(context).size.width,
            height: 250,
          ),
          SizedBox(height: 20,),
          Text(AS.NoTripHistory(),
            maxLines: 1,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,

            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20,),
          OutlineButton(
            child: Text(AS.Explore(),
                style: TextStyle(
                  color: ColorPalette.TextColorRegular,
                  fontSize: 12.0,
                )),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  new MyCustomRoute(
                      builder: (context) => new ProductListingScreen()));
            },
            borderSide: BorderSide(
              color: ColorPalette.TextColorRegular,
              style: BorderStyle.solid,
              width: 0.8,
            ),
          ),



        ],
      ),
    );
  }

  TicketOld() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        //+1 for progressbar
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: PastList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 250,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push( context, MyCustomRoute(builder: (context) => BookingView(getPid: PastList[index]["b_id"],)));
              },
              child:   TicketCard(
                decoration: TicketDecoration(
                    shadow: [TicketShadow(color: Colors.black, elevation: 2)],
                    border: TicketBorder(
                        color: Colors.green,
                        width: 0.1,
                        style: TicketBorderStyle.dotted
                    )
                ),
                lineFromTop: 165,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  color: ColorPalette.book_past,
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Expanded(
                            child: Text(AS.BookingID(),style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 13),),
                          ),
                          Text("#ER0"+PastList[index]["b_id"],style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 13),),
                        ],
                      ),
                      Divider(color: ColorPalette.red,),
                      SizedBox(height: 5,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Expanded(
                            child: Text(AS.Name(),style: TextStyle(color: Colors.black,fontSize: 15),),
                          ),
                          Text(Name.toString(),style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 3,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Expanded(
                            child: Text(AS.Email(),style: TextStyle(color: Colors.black,fontSize: 15),),
                          ),
                          Text(Email,style: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Divider(),
                      SizedBox(height: 3,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.filter_hdr,color: ColorPalette.red,size: 20,),
                          Expanded(
                            child: Text("  "+PastList[index]["p_name"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15),),
                          ),

                        ],
                      ),
                      SizedBox(height: 3,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Icon(Icons.arrow_right,color: ColorPalette.red,size: 20,),
                          Expanded(
                            child: Text("  "+PastList[index]["total_person"]+" "+AS.Person(),style: TextStyle(color: Colors.black,fontSize: 13),),
                          ),
                          Icon(Icons.arrow_right,color: ColorPalette.red,size: 20,),
                          Expanded(
                            child: Text(PastList[index]["days"],style: TextStyle(color: Colors.black,fontSize: 13),),
                          ),
                          Icon(Icons.arrow_right,color: ColorPalette.red,size: 20,),
                          Expanded(
                            child: Text("On "+PastList[index]["booked_dated"],style: TextStyle(color: Colors.black,fontSize: 12),),
                          ),

                        ],
                      ),
                      SizedBox(height: 35,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(AS.Total()+" : ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15),),
                          Expanded(
                            child: Text(PastList[index]["totalprice"]+" AED ",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 15),),
                          ),
                          Container(
                            color: ColorPalette.red,
                            height: 20,
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            alignment: Alignment.center,
                            child: Text(AS.PastTrip(),style: TextStyle(color: Colors.white,fontSize: 10),)  ,
                          ),


                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        controller: _scrollController,
      ),
    );

  }
}