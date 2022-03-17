import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:badges/badges.dart';
import 'package:glen_lms/components/activities.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:glen_lms/components/category.dart';
import 'package:glen_lms/components/heading.dart';

import 'package:glen_lms/components/profile_image.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:wakelock/wakelock.dart';

import '../constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _userId, sapId, dept, role;
  String _name = "";
  String type = "";
  String total_pending_tour = "";
  String total_pending_expense = "";
  String total_lead_follow_assigned = "";
  String _mobile_number;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _getUser();
    initialize();
  }

  Future _userCheck() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
    };
    var response = await http.post(
      Uri.parse(URL + "dashboard"),
      body: {"auth_key": "VrdoCRJjhZMVcl3PIsNdM", "user_id": _userId},
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (data['user_login'] != true) {
        prefs.clear();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          total_lead_follow_assigned = data['total_lead_follow_assigned'].toString();
          prefs.setString('total_lead_follow_assigned',
              data['total_lead_follow_assigned'].toString());
          prefs.setString(
              'total_pending_tour', data['total_pending_tour'].toString());
          prefs.setString('total_pending_expense',
              data['total_pending_expense'].toString());
        });
      }

      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  void initialize() async {
    AndroidInitializationSettings android = new AndroidInitializationSettings(
        '@mipmap/ic_launcher'); //@mipmap/ic_launcher
    IOSInitializationSettings ios = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initSettings = new InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initSettings);
    _fcm.setForegroundNotificationPresentationOptions(
        sound: true, alert: true, badge: true);
    // _fcm.onIosSettingsRegistered.listen((IosNotificationSettings setting) {
    //   print('IOS Setting Registed');
    // });
    showNotification();
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  showNotification() async {
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    var androidPlatformChannelSpecifies = new AndroidNotificationDetails(
      "CA",
      "Courier Alliance",
      // "Courier Alliance",
      importance: Importance.max,
      groupKey: 'iex',
      groupAlertBehavior: GroupAlertBehavior.all,
      priority: Priority.high,
      color: Colors.blue,
      autoCancel: true,
      enableLights: true,
      vibrationPattern: vibrationPattern,
      styleInformation: BigTextStyleInformation(''),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      icon: '@mipmap/ic_launcher',
      playSound: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails(presentAlert: true, presentSound: true);
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifies,
        iOS: iOSPlatformChannelSpecifics);
    // _fcm.configure(
    //   onLaunch: (Map<String, dynamic> msg) async {
    //     print(" onLaunch called ${(msg)}");
    //     Wakelock.enable();
    //     String val = '';
    //     String val2 = '';
    //     val = msg['notification']['title'];
    //     val2 = msg['notification']['body'];
    //     await flutterLocalNotificationsPlugin
    //         .show(0, val, val2, platformChannelSpecifics, payload: 'CA');
    //   },
    //   onResume: (Map<String, dynamic> msg) async {
    //     print(" onResume called ${(msg)}");
    //     Wakelock.enable();
    //     String val = '';
    //     String val2 = '';

    //     val = msg['notification']['title'];
    //     val2 = msg['notification']['body'];
    //     await flutterLocalNotificationsPlugin
    //         .show(0, val, val2, platformChannelSpecifics, payload: 'CA');
    //   },
    //   onMessage: (Map<String, dynamic> msg) async {
    //     print(" onMessage called ${msg}");
    //     String val = '';
    //     Wakelock.enable();
    //     String val2 = '';
    //     val = msg['notification']['title'];
    //     val2 = msg['notification']['body'];
    //     await flutterLocalNotificationsPlugin
    //         .show(0, val, val2, platformChannelSpecifics, payload: 'CA');
    //   },
    // );
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      dept = prefs.getString('dept').toString();
      role = prefs.getString('role').toString();
      sapId = prefs.getString('sap_id').toString();
      _name = prefs.getString('name');
      type = prefs.getString('type');
      _mobile_number = prefs.getString('mobile_number');
      //  if(type!="users") {
      _userCheck();
      // }
    });
  }

  Widget _buildAccountDetail() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          left: 15.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _name.toUpperCase(),
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'SAP ID : ',
                  style: TextStyle(
                    fontSize: 17.0,
                    color: primaryColorLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 3.0,
                ),
                Text(
                  sapId.toString(),
                  style: TextStyle(
                    fontSize: 20.0,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
              ],
            ),
            Text(
              _mobile_number.toString(),
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topInfo(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(
        // horizontal: deviceSize.width * 0.03,
        vertical: deviceSize.height * 0.02,
      ),
      child: Container(
        margin: EdgeInsets.only(
          left: deviceSize.width * 0.1,
        ),
        alignment: Alignment.centerLeft,
        height: deviceSize.height * 0.15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ProfileImage(),
                _buildAccountDetail(),
              ],
            ),
            /* Container(
              height: 8.0,
              width: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(
          "Are you sure",
        ),
        content: new Text("Do you want to exit an App"),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              "No",
              style: TextStyle(
                color: Color(0xff9b56ff),
              ),
            ),
          ),
          new FlatButton(
            onPressed: () {
              exit(0);
            },
            child:
            new Text("Yes", style: TextStyle(color: Color(0xff9b56ff))),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return WillPopScope (
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          /*drawer: Drawer(
            child: Column(
              children: <Widget>[
                buildUserInfo(context),
                buildDrawerItem(),
              ],
            ),
          ),
          appBar: buildAppBar(),
          body: TabBarView(
            children: [

              //FirstScreen(),
              //SecondScreen(),
            ],
          ),*/
          appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text("Target vs Ach.", style: TextStyle(color: Colors.white)),
              bottom: TabBar(
                 tabs: [
                    Tab(text: "CURRENT MONTH"),
                    Tab(text: "LAST MONTH")
                 ],
                unselectedLabelColor: Colors.white,
                indicatorColor: primaryColor,
              ),
          ),
          body: ListView(
              children: [
                 Column(
                    children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("OVERALL TARGET", style: TextStyle(color: Colors.black, fontSize: 21.0)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 5.0, right: 15.0),
                          child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                                 Column(
                                   children: [
                                      Text("\u20B9 400.00", style: TextStyle(color: Colors.blue, letterSpacing: 1.0, fontSize: 16.0)),
                                      Text("Target", style: TextStyle(color: Colors.black, letterSpacing: 1.0, fontSize: 16.0)),
                                   ],
                                 ),
                                 Column(
                                   children: [
                                     Text("\u20B9 400.00", style: TextStyle(color: Colors.green, letterSpacing: 1.0, fontSize: 16.0)),
                                     Text("Achvd", style: TextStyle(color: Colors.black, letterSpacing: 1.0, fontSize: 16.0)),
                                 ],
                               ),
                             ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Container(
                               height: 180.0,
                               width: 180.0,
                               child: SfRadialGauge(
                                 enableLoadingAnimation: true,
                                 animationDuration: 4500,
                                 axes: <RadialAxis>[
                                   RadialAxis(
                                     minimum: 0,
                                     maximum: 80,
                                     pointers: const <GaugePointer>[
                                       NeedlePointer(
                                         value: 40,
                                         enableAnimation: true,
                                       )
                                     ],
                                     ranges: <GaugeRange>[
                                       GaugeRange(startValue: 0, endValue: 30, color: Colors.green),
                                       GaugeRange(startValue: 30, endValue: 70, color: Colors.orange),
                                       GaugeRange(startValue: 70, endValue: 80, color: Colors.red)
                                     ],
                                   )
                                 ],
                               ),
                            )
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5.0, top: 20.0, right: 5.0, bottom: 5.0),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text("BILLED OUTLET TARGET", style: TextStyle(color: Colors.black, fontSize: 16.0))),
                        ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 0.0, right: 5.0, bottom: 5.0),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                               height: 45.0,
                               width: MediaQuery.of(context).size.width,
                               decoration: BoxDecoration(
                                 color: primaryColor,
                                 border: Border.all(
                                     width: 3.0,
                                     color: primaryColor
                                 ),
                                 borderRadius: BorderRadius.all(
                                     Radius.circular(5.0) //                 <--- border radius here
                                 ),
                               ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("104.81%", style: TextStyle(color: Colors.white, letterSpacing: 1.0)),
                              )
                            ),
                       ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text("Achvd - 196", style: TextStyle(color: Colors.green, letterSpacing: 0.0, fontSize: 14.0)),
                             Text("Target - 187", style: TextStyle(color: Colors.blue, letterSpacing: 0.0, fontSize: 14.0)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 20.0, right: 5.0, bottom: 5.0),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text("TODAY ACTIVITIES", style: TextStyle(color: Colors.black, fontSize: 16.0))),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 5.0, right: 0.0, bottom: 5.0),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: GridView.count (
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              // primary: true,
                              children: todayactivity
                                  .map((item) => InkWell(
                                onTap: () {
                                  if (item['title'] ==
                                      "Leads") {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/my-leads',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/my-leads',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name': 'Leads'
                                        },
                                      );
                                    }
                                  } else if (item['title'] ==
                                      'Visits') {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/my-visits',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/my-visits',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name': 'Visits'
                                        },
                                      );
                                    }
                                  } else if (item['title'] ==
                                      'My Dealer/Dist.') {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/my-dealers',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/my-dealers',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          "Dealers/Distributors",
                                          'semi_name':
                                          'Dealers/Distributors'
                                        },
                                      );
                                    }
                                  } else if (item['title'] ==
                                      'Tours') {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/tours',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/tours',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name': 'Tours'
                                        },
                                      );
                                    }
                                  }
                                  /*  else if(item['title']=='My Attendance'){
                                     Navigator.pushNamed(context, '/my-attendance');
                                   }*/
                                  else if (item['title'] ==
                                      'Add Contact') {
                                    Navigator.pushNamed(context,
                                        '/dealer-list');
                                  } else if (item['title'] ==
                                      'Glen Promotion') {
                                    Navigator.pushNamed(context,
                                        '/glen-promotionlist');
                                  } else if (item['title'] ==
                                      'Competition Promotion') {
                                    Navigator.pushNamed(context,
                                        '/competitor-promotionlist');
                                  } else if (item['title'] ==
                                      'Attendance') {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/da-list',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                          'local_type': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/da-list',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                          'local_type': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name':
                                          'Attendance'
                                        },
                                      );
                                    }
                                  } else if (item['title'] ==
                                      'Orders') {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/order-list',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/order-list',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name': 'Orders'
                                        },
                                      );
                                    }
                                  } else if (item['title'] ==
                                      'Sales Target') {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/view-salestarget',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/view-salestarget',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name':
                                          'Sales Target'
                                        },
                                      );
                                    }
                                  } else if (item['title'] ==
                                      'Target Achievement') {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/target-achievement',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/target-achievement',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name':
                                          'Target Achievement'
                                        },
                                      );
                                    }
                                  }
                                  else if (item['title'] ==
                                      "What's New") {
                                    if (role ==
                                        "Sales Executive") {

                                    } else if (role ==
                                        "Sales Promoter") {
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name':
                                          'Target Achievement'
                                        },
                                      );
                                    }
                                  }
                                  else if (item['title'] ==
                                      'Expense Reimbursements') {
                                    if (role ==
                                        "Sales Executive") {
                                      Navigator.pushNamed(
                                        context,
                                        '/expense',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.pushNamed(
                                        context,
                                        '/expense',
                                        arguments: <String,
                                            String>{
                                          'member_id': "",
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/sub-dashboard',
                                        arguments: <String,
                                            String>{
                                          'image':
                                          item['image'],
                                          'sub_name':
                                          item['title']
                                              .toString(),
                                          'semi_name': 'Expense'
                                        },
                                      );
                                    }
                                  }
                                },
                                child: item['title'] == "Leads"
                                    ? Badge(
                                  padding:
                                  EdgeInsets.all(7),
                                  badgeColor: Colors.red,
                                  position: BadgePosition
                                      .topEnd(
                                      top: 1,
                                      end: 15),
                                  animationDuration:
                                  Duration(
                                      milliseconds:
                                      300),
                                  animationType:
                                  BadgeAnimationType.fade,
                                  badgeContent: Text(
                                    total_lead_follow_assigned
                                        .toString(),
                                    style: TextStyle(
                                        color:
                                        Colors.white),
                                  ),
                                  child: Activities(
                                    title: item['title'],
                                    image: item['image'],
                                    subtitle: item['subtitle'],
                                  ),
                                )
                                    : Activities(
                                  title: item['title'],
                                  image: item['image'],
                                  subtitle: item['subtitle'],
                                ),
                              ))
                                  .toList(),
                            ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 20.0, right: 5.0, bottom: 5.0),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text("YESTERDAY ACTIVITIES", style: TextStyle(color: Colors.black, fontSize: 16.0))),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0, top: 5.0, right: 0.0, bottom: 5.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: GridView.count (
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            // primary: true,
                            children: lastdatactivity
                                .map((item) => InkWell(
                              onTap: () {
                                if (item['title'] ==
                                    "Leads") {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/my-leads',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/my-leads',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name': 'Leads'
                                      },
                                    );
                                  }
                                } else if (item['title'] ==
                                    'Visits') {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/my-visits',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/my-visits',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name': 'Visits'
                                      },
                                    );
                                  }
                                } else if (item['title'] ==
                                    'My Dealer/Dist.') {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/my-dealers',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/my-dealers',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        "Dealers/Distributors",
                                        'semi_name':
                                        'Dealers/Distributors'
                                      },
                                    );
                                  }
                                } else if (item['title'] ==
                                    'Tours') {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/tours',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/tours',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name': 'Tours'
                                      },
                                    );
                                  }
                                }
                                /*  else if(item['title']=='My Attendance'){
                                     Navigator.pushNamed(context, '/my-attendance');
                                   }*/
                                else if (item['title'] ==
                                    'Add Contact') {
                                  Navigator.pushNamed(context,
                                      '/dealer-list');
                                } else if (item['title'] ==
                                    'Glen Promotion') {
                                  Navigator.pushNamed(context,
                                      '/glen-promotionlist');
                                } else if (item['title'] ==
                                    'Competition Promotion') {
                                  Navigator.pushNamed(context,
                                      '/competitor-promotionlist');
                                } else if (item['title'] ==
                                    'Attendance') {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/da-list',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                        'local_type': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/da-list',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                        'local_type': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name':
                                        'Attendance'
                                      },
                                    );
                                  }
                                } else if (item['title'] ==
                                    'Orders') {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/order-list',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/order-list',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name': 'Orders'
                                      },
                                    );
                                  }
                                } else if (item['title'] ==
                                    'Sales Target') {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/view-salestarget',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/view-salestarget',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name':
                                        'Sales Target'
                                      },
                                    );
                                  }
                                } else if (item['title'] ==
                                    'Target Achievement') {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/target-achievement',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/target-achievement',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name':
                                        'Target Achievement'
                                      },
                                    );
                                  }
                                }
                                else if (item['title'] ==
                                    "What's New") {
                                  if (role ==
                                      "Sales Executive") {

                                  } else if (role ==
                                      "Sales Promoter") {
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name':
                                        'Target Achievement'
                                      },
                                    );
                                  }
                                }
                                else if (item['title'] ==
                                    'Expense Reimbursements') {
                                  if (role ==
                                      "Sales Executive") {
                                    Navigator.pushNamed(
                                      context,
                                      '/expense',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else if (role ==
                                      "Sales Promoter") {
                                    Navigator.pushNamed(
                                      context,
                                      '/expense',
                                      arguments: <String,
                                          String>{
                                        'member_id': "",
                                      },
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/sub-dashboard',
                                      arguments: <String,
                                          String>{
                                        'image':
                                        item['image'],
                                        'sub_name':
                                        item['title']
                                            .toString(),
                                        'semi_name': 'Expense'
                                      },
                                    );
                                  }
                                }
                              },
                              child: item['title'] == "Leads"
                                  ? Badge(
                                padding:
                                EdgeInsets.all(7),
                                badgeColor: Colors.red,
                                position: BadgePosition
                                    .topEnd(
                                    top: 1,
                                    end: 15),
                                animationDuration:
                                Duration(
                                    milliseconds:
                                    300),
                                animationType:
                                BadgeAnimationType
                                    .fade,
                                badgeContent: Text(
                                  total_lead_follow_assigned
                                      .toString(),
                                  style: TextStyle(
                                      color:
                                      Colors.white),
                                ),
                                child: Category(
                                  title: item['title'],
                                  image: item['image'],
                                ),
                              )
                                  : Category(
                                title: item['title'],
                                image: item['image'],
                              ),
                            ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                 )
              ],
          )
        ),
      ),
    );
  }

  Widget buildDrawerItem() {
    if (type == "users") {
      return Flexible(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (Draw item in drawerItems)
                    InkWell(
                      onTap: () {
                        /*if(item.title=="Orders"){
                        Navigator.pop(context);

                        Navigator.pushNamed(
                          context,
                          '/order-list',
                          arguments: <String, String>{
                            'member_id': "",

                          },
                        );
                      }
                      else
                      if(item.title=="Sales Targets"){
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/view-salestarget',
                          arguments: <String, String>{
                            'member_id': "",

                          },
                        );
                      }*/
                        /*else
                      if(item.title=="Expensive Reimbursements"){
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/expense',
                          arguments: <String, String>{
                            'member_id': "",

                          },
                        );
                      }*/

                        if (item.title == "Glen Promotion") {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/glen-promotionlist');
                        } else if (item.title == "Competition Promotion") {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, '/competitor-promotionlist');
                        }
                      },
                      child: ListTile(
                        leading: Image(
                          image: AssetImage(item.icon),
                          height: 20.0,
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(color: Color(0xff9b56ff)),
                        ),
                      ),
                    ),
                ],
              ),
              InkWell(
                onTap: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  //prefs.remove('logged_in');
                  prefs.clear();
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Flexible(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  //prefs.remove('logged_in');
                  prefs.clear();
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  buildUserInfo(context) => Container(
    color: drawerColoPrimary,
    //height: deviceSize.height * 0.3,
    padding: EdgeInsets.only(bottom: 25.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
          },
          leading: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        /* Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Hlo!',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  _name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),*/
        SizedBox(
          height: 15.0,
        ),
        ProfileImage(
          color: Colors.white,
          height: 70.0,
          width: 70.0,
        ),
        SizedBox(
          height: 15.0,
        ),
        Text(
          _name,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        )
      ],
    ),
  );

  AppBar buildAppBar() {
    return AppBar (
      elevation: 0.0,
      // centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              _name.toUpperCase(),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.pushNamed(context, '/notification-list');
          },
        ),
      ],
      bottom: TabBar(
        tabs: [
          Tab(text: "CURRENT MONTH"),
          Tab(text: "LAST MONTH")
        ],
      ),
    );
  }
}
