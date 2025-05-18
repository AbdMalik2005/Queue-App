import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_app/screens/provider/LogouFun.dart';
import 'package:project_app/screens/provider/Notification.dart';
import 'package:project_app/widget/Employe_queue_card.dart';
import 'package:project_app/widget/Field_employe.dart';
import 'package:project_app/screens/provider/Myalert.dart';
import 'package:project_app/widget/Not_queue.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_app/screens/view/Login.dart';
import 'package:project_app/widget/ShowLoading.dart';

class EmployeScreen extends StatefulWidget {
  EmployeScreen({super.key});

  @override
  State<EmployeScreen> createState() => _EmployeScreenState();
}

class _EmployeScreenState extends State<EmployeScreen> {
  @override
void initState() {
  super.initState();

  // تشغيل كود غير متزامن بعد التهيئة
  Future.microtask(() async {
    // جلب Access Token
    String accessToken = await getAccessToken();
    print('Access Token: $accessToken');

    // جلب FCM Token الخاص بالجهاز الحالي
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $deviceToken');
  });
}

  var Queue_name = TextEditingController();

  String generateRandomCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    String result = '';
    for (int i = 0; i < 6; i++) {
      result += chars[random.nextInt(chars.length)];
    }
    return result;
  }

// دالة انشاء الطابور
  CreateQueue(String name_Q) async {
    try {
      showLoadingDialog (context);
      CollectionReference Queue =
          FirebaseFirestore.instance.collection('Queues');
      await Queue.add({
        'name': name_Q,
        'code': generateRandomCode(),
        'idEmployee': FirebaseAuth
            .instance.currentUser!.uid, // معرف مسؤول الطابور // المنتظرين
        'Currentnumber': 1, // الرقم الحالي
        'NumberClients': 0, // العدد الكلي للعملاء
        'ActiveClients': 0
      });

      print('تم الانشاء');
      Navigator.of(context).pop(); // ❗إغلاق النافذة
      setState(() {
        Queue_name.text = '';
      });
    } catch (e) {
      print('هناك خطأ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Container(
          width: double.infinity,
          child: GestureDetector(
            onTap: () {
              if (Queue_name.text.isNotEmpty)
                CreateQueue(Queue_name.text.trim());
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(
                          'assets/user-_1_.svg',
                          height: 35,
                          color: Color(0xff6B7280),
                        ),
                      ),
                      Text(
                        'Dawri',
                        style: TextStyle(
                            fontFamily: "Myfont",
                            color: Color(0xff872CD8),
                            fontSize: 55),
                      ),
                      IconButton(
                        onPressed: () {
                          Myalert(context, () => Logout(context),
                              'Are you sure you want to log out?');
                        },
                        icon: Icon(
                          color: Color(0xff6B7280),
                          Icons.logout,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FieldEmploye(Queue_name: Queue_name),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                            height: 503,
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Queues')
                                    .where('idEmployee',
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapQueues) {
                                  if (!snapQueues.hasData ||
                                      snapQueues.data!.docs.isEmpty) {
                                    return NotQueue();
                                  }
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapQueues.data!.docs.length,
                                    itemBuilder: (context, index) =>
                                        EmployeQueueCard(
                                      Queue_ID: snapQueues.data!.docs[index].id,
                                      Queue_name: snapQueues.data!.docs[index]
                                          ['name'],
                                      Queue_Active_Clients: snapQueues
                                          .data!.docs[index]['ActiveClients'],
                                      Queue_code: snapQueues.data!.docs[index]
                                          ['code'],
                                      Queue_current_number: snapQueues
                                          .data!.docs[index]['Currentnumber'],
                                    ),
                                  );
                                })),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
