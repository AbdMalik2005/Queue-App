import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_app/screens/provider/LogouFun.dart';
import 'package:project_app/screens/provider/Myalert.dart';
import 'package:project_app/screens/provider/Notification.dart';
import 'package:project_app/screens/view/Login.dart';
import 'package:project_app/widget/Card_your_turn.dart';
import 'package:project_app/widget/Client_queue_card.dart';
import 'package:project_app/widget/Field_client_queue.dart';
import 'package:project_app/widget/My_field.dart';
import 'package:project_app/screens/provider/JoinFun.dart';
import 'package:project_app/widget/Not_queue.dart';

class ClientScreen extends StatefulWidget {
  ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  var Queue_code = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Container(
          width: double.infinity,
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
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Queue_code.text.isNotEmpty) {
                            JoinQeueu(Queue_code.text.trim() , context);
                            Queue_code.clear();
                          }
                        },
                        child: Field_Client_queue(Queue_code: Queue_code),
                      ),
                      SizedBox(height: 50),
                      Container(
                        height: 503,
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .snapshots(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            List joinedQueues =
                                userSnapshot.data?.get('joinedQueues') ?? [];

                            if (joinedQueues.isEmpty) {
                              return Center(child: NotQueue());
                            }

                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Queues')
                                  .where(FieldPath.documentId,
                                      whereIn: joinedQueues)
                                  .snapshots(),
                              builder: (context, queueSnapshot) {
                                if (!queueSnapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: queueSnapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var queueData =
                                        queueSnapshot.data!.docs[index];
                                    String queueId = queueData.id;
                                    int Currentnumber =
                                        queueData['Currentnumber'];
                                    return StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Queues')
                                          .doc(queueId)
                                          .collection('Client')
                                          .where('user_id',
                                              isEqualTo: FirebaseAuth
                                                  .instance.currentUser?.uid)
                                          .where('status', isEqualTo: 'Active')
                                          .snapshots(),
                                      builder: (context, clientSnapshot) {
                                        if (clientSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }

                                        if (clientSnapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  "حدث خطأ أثناء تحميل البيانات"));
                                        }

                                        if (!clientSnapshot.hasData ||
                                            clientSnapshot.data!.docs.isEmpty) {
                                          return SizedBox();
                                        }

                                        var clientData =
                                            clientSnapshot.data!.docs.first;
                                        int yourNumber =
                                            clientData['yourPlace'];
                                        if (yourNumber ==
                                            queueData['Currentnumber']) {
                                          return CardYourTurn(
                                            Queue_name: queueData['name'],
                                            yourNumber: yourNumber,
                                          );
                                        }
                                        return ClientQueueCard(
                                          Queue_ID: queueId,
                                          Queue_name: queueData['name'],
                                          You_number: yourNumber,
                                          Queue_code: queueData['code'],
                                          Queue_current_number:
                                              queueData['Currentnumber'],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
