import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_app/screens/provider/UserToken.dart';

void Myalert(BuildContext context, VoidCallback onConfirm, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Image.asset(
          'assets/warning.png',
          height: 40,
        ),
        content: Text(
          '$text',
          style: TextStyle(fontFamily: "Myfont"),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // ← لون الخلفية
              foregroundColor: Colors.white, // ← لون النص
            ),
            child: Text(
              'Cansle',
              style: TextStyle(fontFamily: "Myfont"),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // يغلق النافذة
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // ← لون الخلفية
              foregroundColor: Colors.white, // ← لون النص
            ),
            child: Text(
              'Sure',
              style: TextStyle(fontFamily: "Myfont"),
            ),
            onPressed: () async {
              Navigator.of(context).pop(); // يغلق النافذة
              onConfirm(); // هنا يمكنك تنفيذ الإجراء الذي تريده بعد التأكيد
              print("تم التأكيد ✅");
            },
          ),
        ],
      );
    },
  );
}
