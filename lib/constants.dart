
import 'dart:ui';

import 'package:flutter/material.dart';

const String BASE_URL = "dev.techstreet.in";
const String API_PATH = "/salesleader/public/api";
const String URL1 = "https://lms.glenindia.com/api/";
const String URL = "https://dev.techstreet.in/salesleader/public/api/";
const Color primaryColor = Color(0xff9b56ff);
const Color primaryColorLight = Color(0xff9b56ff);
const Color drawerColoPrimary = Color(0xff9b56ff);
const String ALERT_DIALOG_TITLE = "Alert";

final String path = 'assets/images/';

final List<Draw> drawerItems = [
 /* Draw(title: 'Orders', icon: path + 'orders.png'),
  Draw(title: 'Sales Targets', icon:  path + 'sales.png'),
  Draw(title: 'Expensive Reimbursements', icon: path + 'expenses.png'),*/
  Draw(title: 'Company Promotion', icon:  path + 'promotion.png'),
  Draw(title: 'Competition Promotion', icon: path + 'competition.png'),
];

final List todayactivity = [
  {'image': path + 'leads.png', 'title': 'Today Leads', 'subtitle': '10'},
  {'image': path + 'visits.png', 'title': 'Toady Follow Up', 'subtitle': '10'},
  {'image': path + 'visits.png', 'title': 'Today Visits', 'subtitle': '10'},
  {'image': path + 'attendance.png', 'title': 'Today Order', 'subtitle': '10'},
];

final List lastdatactivity = [
  {'image': path + 'leads.png', 'title': 'My Working', 'subtitle': ''},
  {'image': path + 'visits.png', 'title': 'Last Working', 'subtitle': ''},
  {'image': path + 'tours.png', 'title': 'Today KM', 'subtitle': ''},
  {'image': path + 'attendance.png', 'title': 'DA', 'subtitle': ''},
  {'image': path + 'attendance.png', 'title': 'Total Order', 'subtitle': ''},
];

final List whatsNew = [
  {'image': path + 'leads.png', 'title': 'Events'},
  {'image': path + 'visits.png', 'title': 'Documents'},
  {'image': path + 'tours.png', 'title': 'Update'},
  {'image': path + 'attendance.png', 'title': 'Gallery'},
];


final List categories = [
  {'image': path + 'leads.png', 'title': 'Leads'},
  {'image': path + 'visits.png', 'title': 'Visits'},
  {'image': path + 'tours.png', 'title': 'Tours'},
  {'image': path + 'attendance.png', 'title': 'Attendance'},
  {'image': path + 'dealer.png', 'title': 'Add Contact'},
  {'image': path + 'orders.png', 'title': 'Orders'},
  {'image': path + 'expenses.png', 'title': 'Expense Reimbursement'},
  {'image': path + 'promotion.png', 'title': 'Company Promotion'},
  {'image': path + 'competition.png', 'title': 'Competition Promotion'},
  {'image': path + 'sales.png', 'title': 'Sales Target'},
  {'image': path + 'achievement.png', 'title': 'Target Achievement'},
  {'image': path + 'worker.png', 'title': 'My Dealer/Dist.'},
  {'image': path + 'worker.png', 'title': "What's New"},
  {'image': path + 'worker.png', 'title': 'My Task'},

];
final List categories1 = [
  {'image': path + 'leads.png', 'title': 'Leads'},

];


class Draw {
  final String title;
  final String icon;
  Draw({this.title, this.icon});
}
