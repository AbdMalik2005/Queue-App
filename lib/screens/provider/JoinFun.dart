import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project_app/widget/ShowLoading.dart';

Future<void> JoinQeueu(String code_qeueu, BuildContext context) async {
  if (code_qeueu.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter the queue code.")));
    print("⚠️ الرجاء إدخال كود الطابور");
    return;
  }

  showLoadingDialog(context); // ✅ عرض دائرة التحميل

  try {
    // جلب الطابور باستخدام الكود
    var queueSnapshot = await FirebaseFirestore.instance
        .collection('Queues')
        .where('code', isEqualTo: code_qeueu.trim())
        .limit(1)
        .get();

    if (queueSnapshot.docs.isEmpty) {
      Navigator.of(context).pop(); // ❗إغلاق النافذة
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("The queue does not exist.")));
      print("The queue does not exist.");
      return;
    }

    String queueID = queueSnapshot.docs.first.id;

    // جلب بيانات المستخدم
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    DocumentSnapshot userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      Navigator.of(context).pop();
      return;
    }

    var userData = userSnapshot.data() as Map<String, dynamic>;
    List joinedQueues = userData['joinedQueues'] ?? [];
    String username = userData['name'];

    if (joinedQueues.contains(queueID)) {
      Navigator.of(context).pop(); // ❗إغلاق النافذة
      print("⚠️ أنت بالفعل منضم إلى هذا الطابور");
      return;
    }

    DocumentReference queueDoc =
        FirebaseFirestore.instance.collection('Queues').doc(queueID);
    CollectionReference clientCollection = queueDoc.collection('Client');

    // ✅ التحقق من إذا كان الطابور فارغ من العملاء
    var clientsSnapshot = await clientCollection
        .where(
          'status',
          isEqualTo: 'Active',
        )
        .get();
    bool isQueueEmpty = clientsSnapshot.docs.isEmpty;

    // ✅ تنفيذ المعاملة
    await FirebaseFirestore.instance.runTransaction((trans) async {
      var queueData = await trans.get(queueDoc);
      if (!queueData.exists) return;

      var data = queueData.data() as Map<String, dynamic>;

      // تحديد رقم العميل بناءً على إذا كان الطابور فارغ
      int yourPlace = isQueueEmpty
          ? data['Currentnumber'] // إذا كان الطابور فارغ
          : data['NumberClients'] + 1; // إذا كان يحتوي على عملاء

      trans.update(queueDoc, {
        'NumberClients': FieldValue.increment(1),
        'ActiveClients': FieldValue.increment(1),
      });

      // إضافة العميل للطابور
      clientCollection.add({
        'name': username,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'status': 'Active',
        'yourPlace': yourPlace,
      });
    });

    await addQueuetoUser(queueID); // ✅ إضافة الطابور للمستخدم
    Navigator.of(context).pop(); // ✅ إغلاق دائرة التحميل
  } catch (e) {
    Navigator.of(context).pop(); // ❗إغلاق دائرة التحميل في حالة الخطأ
    print("❌ خطأ أثناء الانضمام للطابور: $e");
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
      child: SizedBox(
        height: 300,
        child: MobileScanner(onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              String scannedCode = barcode.rawValue!;
              Navigator.pop(context);
              JoinQeueu(scannedCode, context);
              break;
            }
          }
        }),
      ),
    ),
  );
}
