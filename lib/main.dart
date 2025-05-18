import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // تم إضافتها هنا ✅
import 'package:project_app/screens/view/Client_screen.dart';
import 'package:project_app/screens/view/Employe_screen.dart';
import 'package:project_app/screens/view/Login.dart';
import 'package:project_app/screens/view/Signup.dart';

Future<void> Notification_background(RemoteMessage message) async {
  print('back=====================================');
  print(message.notification!.title);
  print(message.notification!.body);
  print('back=====================================');
}

MyrequestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(Notification_background);
  MyrequestPermission();
  runApp(
  //    DevicePreview(
  // enabled: true,
  //   builder: (context) => Myapp(), // Wrap your app
  // ),
    Myapp() 
    
    );
}

class Myapp extends StatefulWidget {
  const Myapp({super.key});

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
  designSize: const Size(360, 690),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      builder: (context, widget) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: DevicePreview.appBuilder(context, widget),
        );
      },
      locale: DevicePreview.locale(context),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? Signup_app()
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Login_app();
                }
                String? state = snapshot.data?.get('state');
                if (state == 'Employee') {
                  return EmployeScreen();
                } else {
                  return ClientScreen();
                }
              }),
      routes: {
        'signup': (context) => Signup_app(),
        'login': (context) => Login_app(),
      },
    );
  },
);

  }
}
