import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_app/screens/provider/UserToken.dart';
import 'package:project_app/screens/view/Login.dart';
import 'package:project_app/widget/ShowLoading.dart';

Logout(BuildContext context) async {
  showLoadingDialog(context);

  try {
    await removeFcmTokenFromUser();
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Login_app()),
      (route) => false,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج')),
    );
  }
}
