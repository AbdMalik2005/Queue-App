import 'package:flutter/material.dart';

class NotQueue extends StatelessWidget {
  const NotQueue({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "You\nhave no\nqueues!",
        style: TextStyle(
            fontSize: 80, fontFamily: "Myfont", color: Color(0xff872CD8)),
      ),
    );
  }
}
