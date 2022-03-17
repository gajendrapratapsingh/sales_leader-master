import 'dart:convert';
import 'dart:typed_data';

import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:glen_lms/components/category.dart';
import 'package:glen_lms/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WhatsNewScreen extends StatefulWidget {
  const WhatsNewScreen({Key key}) : super(key: key);

  @override
  _WhatsNewScreenState createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends State<WhatsNewScreen> {

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

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "What's New",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[

        ],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Stack (
        children: <Widget>[
          Container(
            color: primaryColor,
            height: deviceSize.height * 0.1,
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: deviceSize.width * 0.03,
            ),
            child: Column(
              children: <Widget>[
                //_topInfo(context),
                type == "users"
                    ? Flexible(
                  fit: FlexFit.tight,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: 25.0,
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: GridView.count (
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              // primary: true,
                              children: whatsNew
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
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => WhatsNewScreen()));
                                    } else if (role ==
                                        "Sales Promoter") {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => WhatsNewScreen()));
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
                        ],
                      ),
                    ],
                  ),
                )
                    : Flexible(
                  fit: FlexFit.tight,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: 25.0,
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              // primary: true,
                              children: categories1
                                  .map((item) => InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/my-leads',
                                    arguments: <String, String>{
                                      'member_id': "",
                                    },
                                  );
                                },
                                child: Badge(
                                  padding: EdgeInsets.all(7),
                                  badgeColor: Colors.red,
                                  position:
                                  BadgePosition.topEnd(
                                      top: 0, end: 15),
                                  animationDuration: Duration(
                                      milliseconds: 300),
                                  animationType:
                                  BadgeAnimationType.slide,
                                  badgeContent: Text(
                                    total_lead_follow_assigned,
                                    style: TextStyle(
                                        color: Colors.white),
                                  ),
                                  child: Category(
                                    title: item['title'],
                                    image: item['image'],
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
