import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/screens/view/Login.dart';
import 'package:project_app/widget/My_field.dart';
import 'package:project_app/widget/ShowLoading.dart';
import 'package:project_app/widget/chagestate.dart';

class Signup_app extends StatefulWidget {
  Signup_app({super.key});

  @override
  State<Signup_app> createState() => _Signup_appState();
}

class _Signup_appState extends State<Signup_app> {
  var email = TextEditingController();
  var pass = TextEditingController();
  var user = TextEditingController();
  String selectedstate = '';

  Future<void> signup() async {
    if (email.text.isEmpty ||
        pass.text.isEmpty ||
        user.text.isEmpty ||
        selectedstate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إكمال جميع الحقول')),
      );
      return;
    }
    showLoadingDialog(context);

    try {
      // إنشاء حساب في Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );

      // إضافة بيانات المستخدم في Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
        'name': user.text.trim(),
        'email': email.text.trim(),
        'state': selectedstate,
        'joinedQueues': [],
      });

      // توجيه المستخدم إلى الشاشة المناسبة
      if (selectedstate == 'Employee') {
          Navigator.of(context).pop(); // إغلاق شاشة التحميل
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Login_app()),
          (route) => false,
        );
        
      } else {
          Navigator.of(context).pop(); // إغلاق شاشة التحميل
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Login_app()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // إغلاق شاشة التحميل
      String message = 'حدث خطأ أثناء التسجيل';
      if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة جداً';
      } else if (e.code == 'email-already-in-use') {
        message = 'البريد الإلكتروني مستخدم بالفعل';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ غير متوقع')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Dawri",
                  style: TextStyle(
                    fontFamily: "Myfont",
                    fontSize: 80.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff872CD8),
                  ),
                ),
              ),
              Text(
                "Signup",
                style: TextStyle(
                  fontFamily: "Myfont",
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff872CD8),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              ChangeStateuser(
                selectedstate: selectedstate,
                onStateChanged: (state) {
                  setState(() {
                    selectedstate = state;
                  });
                },
              ),
              SizedBox(height: 30.h),
              My_field(
                hint: "Username",
                controller: user,
              ),
              SizedBox(height: 16.h),
              My_field(
                hint: "Email",
                controller: email,
              ),
              SizedBox(height: 16.h),
              My_field(
                hint: "Password",
                controller: pass,
                obscure: true,
                obscureactive: true,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80.r),
                  child: ElevatedButton(
                    onPressed: signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff2CD87D),
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      "Signup",
                      style: TextStyle(
                          fontFamily: "Myfont",
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.r),
                child: Divider(thickness: 3, color: Colors.grey.shade300),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Login_app()),
                    (route) => false,
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                      fontFamily: "Myfont",
                      color: Color(0xff872CD8),
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
