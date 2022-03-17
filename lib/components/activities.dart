import 'package:flutter/material.dart';
class Activities extends StatelessWidget {

  final String image, title, subtitle;

  Activities({this.title, this.image, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 10.0, bottom: 10.0),
      child: Container(
        height: 130.0,
        width: 130.0,
        child: Column (
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
               Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Image.asset(image, height: 40.0, color: Color(0xff9b56ff)),
               ),
               SizedBox(
                 height: 10.0,
               ),
               Text(
                 title,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                 fontSize: 14.0,
                 fontWeight: FontWeight.w400,
               ),
               ),
               SizedBox(
                 height: 5.0,
               ),
               Text(
                 subtitle,
                 textAlign: TextAlign.center,
               style: TextStyle(
                  fontSize: 14.0,
                 fontWeight: FontWeight.w400,
               )
        ),
           ],
        ),
      ),
    );
  }
}
