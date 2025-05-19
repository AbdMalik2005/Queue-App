import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_app/screens/view/List_Client.dart';
import 'package:project_app/screens/provider/Myalert.dart';
import 'package:project_app/widget/ShowLoading.dart';

class EmployeQueueCard extends StatelessWidget {
  final String Queue_name;
  final String Queue_code;
  final int Queue_Active_Clients;
  final int Queue_current_number;
  final String Queue_ID;
  const EmployeQueueCard({
    super.key,
    required this.Queue_name,
    required this.Queue_code,
    required this.Queue_Active_Clients,
    required this.Queue_current_number,
    required this.Queue_ID,
  });
  DeletQueue(BuildContext context) async {
    // String queueId = snapQueues.data!.docs[index].id;
    String queueId = Queue_ID;
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    try {
      // **1️⃣ جلب جميع العملاء من مجموعة Client الفرعية لهذا الطابور**
      QuerySnapshot clientsSnapshot = await FirebaseFirestore.instance
          .collection('Queues')
          .doc(queueId)
          .collection('Client')
          .get();

      // **2️⃣ تحديث كل عميل لإزالة معرف الطابور من joinedQueues**
      for (var clientDoc in clientsSnapshot.docs) {
        String clientId = clientDoc['user_id']; // معرف المستخدم

        await usersCollection.doc(clientId).update({
          'joinedQueues': FieldValue.arrayRemove([queueId])
        });
      }

      // **3️⃣ حذف الطابور بالكامل**
      await FirebaseFirestore.instance
          .collection('Queues')
          .doc(queueId)
          .delete();

      print('✅ تم حذف الطابور وتحديث بيانات العملاء بنجاح.');
    } catch (e) {
      print('⚠️ حدث خطأ أثناء الحذف: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ListOfClient(
              Queue_name :Queue_name,
                Queue_code: Queue_code,
                Current_number: Queue_current_number,
                Queue_ID: Queue_ID)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 17),
        padding: EdgeInsets.all(30),
        width: 347,
        height: 503,
        decoration: BoxDecoration(
            color: Color(0xff872CD8), borderRadius: BorderRadius.circular(35)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$Queue_name',
                    overflow: TextOverflow.ellipsis, // تظهر "..."
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 30, color: Colors.white, fontFamily: "Myfont"),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Myalert(context, () {
                      DeletQueue(context);
                    }, "Are you sure about removing the queue?");
                  },
                  child: Image.asset(
                    'assets/multiply.png',
                    height: 35,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Clients :',
              style: TextStyle(
                  fontSize: 35, color: Colors.white, fontFamily: "Myfont"),
            ),
            Text(
              '$Queue_Active_Clients',
              style: TextStyle(
                  fontSize: 60, color: Colors.white, fontFamily: "Myfont"),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Current Number :',
              style: TextStyle(
                  fontSize: 30, color: Colors.white, fontFamily: "Myfont"),
            ),
            Text(
              '$Queue_current_number',
              style: TextStyle(
                  fontSize: 60, color: Colors.white, fontFamily: "Myfont"),
            ),
            Text(
              'Code : $Queue_code',
              style: TextStyle(
                  fontSize: 30, color: Colors.white, fontFamily: "Myfont"),
            ),
          ],
        ),
      ),
    );
  }
}
