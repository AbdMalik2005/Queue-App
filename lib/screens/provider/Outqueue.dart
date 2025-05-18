import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


OutQueue(String Queue_ID) async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference queueDoc =
        FirebaseFirestore.instance.collection('Queues').doc(Queue_ID);
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('Users').doc(userId);
//
    WriteBatch Mybath = FirebaseFirestore.instance.batch();
    Mybath.update(queueDoc, {'ActiveClients': FieldValue.increment(-1)});
    await Mybath.commit();
    // 🔹 1. التحقق من وجود العميل في الطابور
    QuerySnapshot stateClient = await queueDoc
        .collection('Client')
        .where('status', isEqualTo: 'Active')
        .where('user_id', isEqualTo: userId)
        .get();

    if (stateClient.docs.isEmpty) {
      print('⚠️ العميل غير موجود في هذا الطابور.');
      return;
    }

    String clientID = stateClient.docs.first.id;

    await userDoc.update({
      'joinedQueues': FieldValue.arrayRemove([Queue_ID])
    });

    // 🔹 4. تحديث حالة العميل إلى "خارج"
    await queueDoc.collection('Client').doc(clientID).update({
      'status': 'NotActive',
    });

    print('✅ تم خروج العميل من الطابور بنجاح!');
  } catch (e) {
    print('❌ خطأ أثناء خروج العميل من الطابور: $e');
  }
}
