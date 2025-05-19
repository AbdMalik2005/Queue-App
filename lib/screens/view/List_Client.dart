import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_app/screens/provider/Show_qr.dart';
import 'package:project_app/widget/Client_info_card.dart';

class ListOfClient extends StatelessWidget {
  final String Queue_ID;
  final int Current_number;
  final String Queue_code;
  final String Queue_name;

  const ListOfClient(
      {super.key,
      required this.Queue_ID,
      required this.Current_number,
      required this.Queue_code,
      required this.Queue_name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset(
                      'assets/turn-back.svg',
                      height: 35,
                      color: Color(0xff6B7280),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Dawri',
                    style: TextStyle(
                      fontFamily: "Myfont",
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff872CD8),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 24,
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                Queue_name,
                overflow: TextOverflow.ellipsis, // تظهر "..."
                maxLines: 1,
                style: TextStyle(
                  fontFamily: "Myfont",
                  fontSize: 30,
                  color: Color(0xff872CD8),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  showQueueInfo(context, Queue_code);
                },
                child: CircleAvatar(
                    backgroundColor: Color(0xff872CD8),
                    radius: 25,
                    child: SvgPicture.asset(
                      'assets/barcode.svg',
                      height: 25,
                      color: Colors.white,
                    )),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Queues')
                      .doc(Queue_ID)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<DocumentSnapshot> queueSnapshot) {
                    if (!queueSnapshot.hasData)
                      return CircularProgressIndicator();

                    int currentNumber = queueSnapshot.data!['Currentnumber'];

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Queues')
                          .doc(Queue_ID)
                          .collection('Client')
                          .where('status', whereIn: ['Active'])
                          .orderBy('yourPlace', descending: false)
                          .limit(5)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  "No Clients",
                                  style: TextStyle(
                                      fontFamily: "Myfont", fontSize: 30),
                                ),
                                Image.asset(
                                  'assets/empty-folder.png',
                                  width: 300,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) => ClientInfoCard(
                            Client_ID: snapshot.data!.docs[index].id,
                            Current_number: currentNumber,
                            Client_User_ID: snapshot.data!.docs[index]
                                ['user_id'],
                            Client_name: snapshot.data!.docs[index]['name'],
                            Client_Number: snapshot.data!.docs[index]
                                ['yourPlace'],
                            Client_State: snapshot.data!.docs[index]['status'],
                            Queue_Id: Queue_ID,
                          ),
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
    );
  }
}
