import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

Future<String> getAccessToken() async {
  try {
    // 1️⃣ تحميل ملف الخدمة (المفتاح السري لحساب Firebase)
    final jsonString = await rootBundle.loadString(
      'assets/notification/queueapp-cc500-firebase-adminsdk-fbsvc-4a82a61ca5.json',
    );

    // 2️⃣ تحويل النص إلى كائن JSON
    final jsonMap = json.decode(jsonString);

    // 3️⃣ إنشاء كائن بيانات الاعتماد لحساب الخدمة
    final accountCredentials = auth.ServiceAccountCredentials.fromJson(jsonMap);

    // 4️⃣ استخدام بيانات الاعتماد للحصول على Access Token
    final client = await auth.clientViaServiceAccount(
      accountCredentials,
      [
        'https://www.googleapis.com/auth/firebase.messaging'
      ], // الصلاحيات المطلوبة
    );

    // 5️⃣ إرجاع الـ Access Token
    print("✅ تم إنشاء Access Token بنجاح");

    return client.credentials.accessToken.data;
  } catch (e) {
    // 6️⃣ في حالة حدوث خطأ أثناء جلب التوكن
    print("❌ خطأ أثناء جلب Access Token: $e");
    return "";
  }
}

Future<void> sendmass(String title, String body, String YourToken) async {
  // الحصول على token الوصول
  final accessToken = await getAccessToken();

  // التحقق من وجود token الوصول
  if (accessToken.isEmpty) {
    print("فشل في الحصول على Access Token");
    return;
  }

  // إعداد headers الطلب
  var headersList = {
    'Accept': '*/*',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };
  print(accessToken);
  print(YourToken);
  // رابط API لإرسال الإشعارات عبر Firebase
  var url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/queueapp-cc500/messages:send');

  // بناء محتوى الإشعار
  var requestBody = {
    "message": {
      "token": "$YourToken", // يجب استبدال هذا ب FCM Token الفعلي
      "notification": {
        "title": title,
        "body": body,
      },
    }
  };

  // إرسال الطلب إلى FCM
  try {
    var response = await http.post(
      url,
      headers: headersList,
      body: jsonEncode(requestBody),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode != 200) {
      print("فشل في إرسال الإشعار: ${response.body}");
    }
  } catch (e) {
    print("حدث خطأ أثناء إرسال الإشعار: $e");
  }
}
