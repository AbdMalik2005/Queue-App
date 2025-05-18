import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_app/screens/provider/Notification.dart';

class CardYourTurn extends StatefulWidget {
  final String Queue_name;
  final int yourNumber;

  const CardYourTurn({
    super.key,
    required this.Queue_name,
    required this.yourNumber,
  });

  @override
  State<CardYourTurn> createState() => _CardYourTurnState();
}

class _CardYourTurnState extends State<CardYourTurn> {
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17),
      padding: EdgeInsets.all(30),
      width: 347,
      // height: 503,
      decoration: BoxDecoration(
          color: Color(0xff2CD87D), borderRadius: BorderRadius.circular(35)),
      child: Column(
        children: [
          Expanded(
            child: Text(
              overflow: TextOverflow.ellipsis, // تظهر "..."
                      maxLines: 1,
              widget.Queue_name,
              style: TextStyle(
                  fontSize: 30, color: Colors.white, fontFamily: "Myfont"),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "It's\nYour\nTurn",
            style: TextStyle(
                fontSize: 75, color: Colors.white, fontFamily: "Myfont"),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Your Number : ${widget.yourNumber}',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontFamily: "Myfont"),
          ),
        ],
      ),
    );
  }
}
