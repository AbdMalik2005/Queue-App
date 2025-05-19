import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project_app/widget/ShowLoading.dart';

Future<void> JoinQeueu(String code_qeueu, BuildContext context) async {
  if (code_qeueu.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enter the queue code.")),
    );
    print("⚠️ الرجاء إدخال كود الطابور");
    return;
  }

  try {
    // جلب الطابور باستخدام الكود
    var queueSnapshot = await FirebaseFirestore.instance
        .collection('Queues')
        .where('code', isEqualTo: code_qeueu.trim())
        .limit(1)
        .get();

    if (queueSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("The queue does not exist.")),
      );
      print("❌ الطابور غير موجود");
      return;
    }

    String queueID = queueSnapshot.docs.first.id;

    // جلب بيانات المستخدم
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    DocumentSnapshot userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      print("❌ المستخدم غير موجود في قاعدة البيانات");
      return;
    }

    var userData = userSnapshot.data() as Map<String, dynamic>;
    List joinedQueues = userData['joinedQueues'] ?? [];
    String username = userData['name'];

    if (joinedQueues.contains(queueID)) {
      print("⚠️ أنت بالفعل منضم إلى هذا الطابور");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are already in this queue.")),
      );
      return;
    }

    DocumentReference queueDoc =
        FirebaseFirestore.instance.collection('Queues').doc(queueID);
    CollectionReference clientCollection = queueDoc.collection('Client');

    // التحقق من وجود عملاء حاليًا
    var clientsSnapshot =
        await clientCollection.where('status', isEqualTo: 'Active').get();
    bool isQueueEmpty = clientsSnapshot.docs.isEmpty;

    // تنفيذ المعاملة
    await FirebaseFirestore.instance.runTransaction((trans) async {
      var queueData = await trans.get(queueDoc);
      if (!queueData.exists) return;

      var data = queueData.data() as Map<String, dynamic>;

      int yourPlace =
          isQueueEmpty ? data['Currentnumber'] : data['NumberClients'] + 1;

      trans.update(queueDoc, {
        'NumberClients': FieldValue.increment(1),
        'ActiveClients': FieldValue.increment(1),
      });

      clientCollection.add({
        'name': username,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'status': 'Active',
        'yourPlace': yourPlace,
      });
    });

    // تحديث بيانات المستخدم
    await addQueuetoUser(queueID);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Successfully joined the queue!")),
    );
  } catch (e) {
    print("❌ خطأ أثناء الانضمام للطابور: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred while joining the queue.")),
    );
  }
}

Future<void> addQueuetoUser(String queueId) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentReference userDoc =
      FirebaseFirestore.instance.collection('Users').doc(userId);
  try {
    await userDoc.update({
      'joinedQueues': FieldValue.arrayUnion([queueId])
    });
    print('✅ تم تحديث قائمة الطوابير بنجاح!');
  } catch (e) {
    print('⚠️ خطأ في تحديث قائمة الطوابير: $e');
  }
}

void scanQRCode(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 🟢 انحناء الزوايا
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // 🟢 قص الحواف الداخلية أيضًا
        child: SizedBox(
          height: 300,
          width: 300,
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  String scannedCode = barcode.rawValue!;
                  Navigator.pop(context);
                  Future.microtask(() {
                    JoinQeueu(scannedCode, context);
                  });
                  break;
                }
              }
            },
          ),
        ),
      ),
    ),
  );
}
