import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/screens/provider/UserToken.dart';
import 'package:project_app/screens/view/Client_screen.dart';
import 'package:project_app/screens/view/Employe_screen.dart';
import 'package:project_app/screens/view/Signup.dart';
import 'package:project_app/widget/My_field.dart';
import 'package:project_app/widget/ShowLoading.dart';

class Login_app extends StatefulWidget {
  Login_app({super.key});

  @override
  State<Login_app> createState() => _Login_appState();
}

class _Login_appState extends State<Login_app> {
  var email = TextEditingController();
  var pass = TextEditingController();

  Future<void> loginUser() async {
    if (email.text.isEmpty || pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور')));
      return;
    }

    showLoadingDialog(context);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );
      await saveFcmTokenToUser();

      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(credential.user!.uid)
          .get();

      if (userData.exists) {
        String userType = userData['state'];

        if (userType == "Client") {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ClientScreen()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => EmployeScreen()));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر العثور على بيانات المستخدم')));
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // إغلاق شاشة التحميل

      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      if (e.code == 'user-not-found') {
        errorMessage = 'البريد الإلكتروني غير مسجل';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني غير صالح';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ غير متوقع: $e')));
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
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
              FittedBox(
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontFamily: "Myfont",
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff872CD8),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
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
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () async {
                        if (email.text.trim().isEmpty)
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Email is empty')));
                        else if (email.text.trim().isNotEmpty) {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني')));
                        }
                      },
                      child: Text("Forget password?"))),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80.w),
                  child: ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff2CD87D),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: FittedBox(
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontFamily: "Myfont",
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.w),
                child: Divider(thickness: 3.h, color: Colors.grey.shade300),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Signup_app()),
                    (route) => false,
                  );
                },
                child: FittedBox(
                  child: Text(
                    "Create an account",
                    style: TextStyle(
                        fontFamily: "Myfont",
                        color: Color(0xff872CD8),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
