import 'dart:ui';

import 'package:dulno/config/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class DulnoNotification {
  Future<void> setup() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await initializeLocalNotifications();
    FirebaseMessaging.instance.subscribeToTopic("dulno");
    FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> initializeLocalNotifications() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    var androidInitialize = AndroidInitializationSettings("notification");
    var iosInitialize = DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
  await processFirebaseMessage(message);
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await processFirebaseMessage(message);
}

Future<void> processFirebaseMessage(RemoteMessage message) async {
  if (message.data.isEmpty) {
    return;
  }
  String? title = message.data['title'];
  String? body = message.data['body'];
  await showLocalNotification(title, body);
}

Future<void> showLocalNotification(String? title, String? body) async {
  const storage = FlutterSecureStorage();
  if ((await storage.read(key: "notifications") ?? "") == "false") {
    return;
  }
  var androidDetails = AndroidNotificationDetails("dulno", "Dulno",
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: const Color.fromARGB(255, 255, 255, 255));
  var iosDetails = DarwinNotificationDetails();
  var notificationDetails =
      NotificationDetails(android: androidDetails, iOS: iosDetails);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}
