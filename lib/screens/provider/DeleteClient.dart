import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/screens/provider/Notification.dart';

Future<void> DeleteClient(
  String QueueId,
  String ClientId,
  String Clientstate,
  String Client_user_id,
) async {
  try {
    // الوصول إلى مرجع الطابور
    DocumentReference queuedoc =
        FirebaseFirestore.instance.collection('Queues').doc(QueueId);

    // الوصول إلى مرجع العميل
    DocumentReference clientdoc = FirebaseFirestore.instance
        .collection('Queues')
        .doc(QueueId)
        .collection('Client')
        .doc(ClientId);

    print("تم الوصول إلى الطابور والعميل:\n$QueueId\n$ClientId");

    // الحصول على رقم العميل الحالي
    final clientSnapshot = await clientdoc.get();
    final currentClientNumber = clientSnapshot['yourPlace'];

    // البحث عن العميل التالي حسب رقم الانتظار
    final nextClientSnapshot = await FirebaseFirestore.instance
        .collection('Queues')
        .doc(QueueId)
        .collection('Client')
        .where('yourPlace', isGreaterThan: currentClientNumber)
        .where('status', isEqualTo: 'Active') // تحقق من الحالة المناسبة
        .orderBy('yourPlace')
        .limit(5)
        .get();

    int newCurrentNumber;
    if (nextClientSnapshot.docs.isNotEmpty) {
      // تم العثور على عميل تالٍ
      newCurrentNumber = nextClientSnapshot.docs.first['yourPlace'];
      ////// اشعار العميل التالي
      var ClientID = nextClientSnapshot.docs.first['user_id'];
      // Users -> ClientID -> fcmTokens ;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(ClientID)
          .get();

      List<dynamic> fcmTokens = userDoc.get('fcmTokens');
      for (String token in fcmTokens) {
        sendmass("تنبيه !", "حان دورك الان", token);
        /////// العميل الخامس
        if (nextClientSnapshot.docs.length >= 5) {
          // العميل الخامس موجود
          var fifthClientDoc = nextClientSnapshot.docs[4];
          var clientID = fifthClientDoc['user_id'];

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(clientID)
              .get();

          List<dynamic> fcmTokens = userDoc.get('fcmTokens');

          for (String token in fcmTokens) {
            sendmass("استعد!", "تبقّى 4 أشخاص فقط على دورك", token);
          }
        }
      }
    } else {
      // لا يوجد عملاء بعده، نزيد الرقم الحالي بـ 1
      newCurrentNumber = currentClientNumber + 1;
    }

    // بدء عملية التحديث باستخدام batch
    WriteBatch Mybath = FirebaseFirestore.instance.batch();

    Mybath.update(queuedoc, {
      'Currentnumber': newCurrentNumber,
      'ActiveClients': FieldValue.increment(-1),
    });

    // تحديث حالة العميل نفسه
    Mybath.update(clientdoc, {'status': 'NotActive'});

    // تنفيذ التحديثات
    try {
      await Mybath.commit();
      print('✅ تم تغيير معلومات العميل والطابور بنجاح');

      // if (Clientstate == 'Active') {
      // إزالة الطابور من قائمة الطوابير المنضّم إليها في حساب المستخدم
      await FirebaseFirestore.instance.runTransaction((trans) async {
        DocumentSnapshot snapshot = await trans.get(clientdoc);
        if (snapshot.exists) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(Client_user_id)
              .update({
            'joinedQueues': FieldValue.arrayRemove([QueueId])
          });
        }
      });
      print("✅ تم حذف هذا الطابور من قائمة العميل");
      // }
    } catch (batchError) {
      print('❌ فشل في تحديث البيانات: $batchError');
      throw batchError;
    }
  } catch (e) {
    print("❌ حدث خطأ في عملية حذف العميل: $e");
    throw e;
  }
}

// // QueueEd
// // ClientId
// //ClientState
// import 'package:cloud_firestore/cloud_firestore.dart';

// DeleteClient(
//   String QueueId,
//   String ClientId,
//   String Clientstate,
//   String Client_user_id,
// ) async {
//   try {
//     // الوصول الى الطابور
//     DocumentReference queuedoc =
//         FirebaseFirestore.instance.collection('Queues').doc(QueueId);
//     print('تم الوصول الى الطابور المقصود');

//     //الوصول الى العميل
//     DocumentReference clientdoc = FirebaseFirestore.instance
//         .collection('Queues')
//         .doc(QueueId)
//         .collection('Client')
//         .doc(ClientId);
//     print('تم الوصول الى العميل المقصود');
//     print("$QueueId\n$ClientId");

//     WriteBatch Mybath = FirebaseFirestore.instance.batch();
//     if (Clientstate == 'Active')
//       Mybath.update(queuedoc, {
//         'Currentnumber': FieldValue.increment(1),
//         'ActiveClients': FieldValue.increment(-1)
//       });
//     else
//       Mybath.update(queuedoc, {
//         'Currentnumber': FieldValue.increment(1),
//       });

//     Mybath.update(clientdoc, {'status': 'done'});

//     // التحقق من نجاح عملية الـ commit
//     try {
//       await Mybath.commit();
//       print('تم تغيير معلومات العميل و الطابور بنجاح');

//       if (Clientstate == 'Active') {
//         //
//         await FirebaseFirestore.instance.runTransaction((trans) async {
//           DocumentSnapshot snapshot = await trans.get(clientdoc);
//           if (snapshot.exists) {
//             await FirebaseFirestore.instance
//                 .collection('Users')
//                 .doc(Client_user_id)
//                 .update({
//               'joinedQueues': FieldValue.arrayRemove([QueueId])
//             });
//           }
//         });
//         print("تم حذف هذا الطابور من قائمة العميل");
//       }
//     } catch (batchError) {
//       print('فشل في تحديث البيانات: $batchError');
//       throw batchError; // إعادة رمي الخطأ للتعامل معه في المستوى الأعلى
//     }
//   } catch (e) {
//     print("حدث خطأ في عملية حذف العميل: $e");
//     throw e; // إعادة رمي الخطأ للتعامل معه في المستوى الأعلى
//   }
// }
