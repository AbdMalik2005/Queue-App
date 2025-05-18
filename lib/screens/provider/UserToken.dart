import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveFcmTokenToUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken == null) return;

  final userDoc = FirebaseFirestore.instance.collection('Users').doc(user.uid);

  await userDoc.set({
    'fcmTokens': FieldValue.arrayUnion([fcmToken]),
  }, SetOptions(merge: true));
}


Future<void> removeFcmTokenFromUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken == null) return;

  final userDoc = FirebaseFirestore.instance.collection('Users').doc(user.uid);

  await userDoc.update({
    'fcmTokens': FieldValue.arrayRemove([fcmToken]),
  });
}
