import 'dart:async';

import 'package:dulno/config/firebase_options.dart';
import 'package:dulno/product/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var data = message.data;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(["en", "de"]);
  runApp(DulnoApp());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.subscribeToTopic("dulno-workspace-monitor");
}

class DulnoApp extends StatelessWidget {
  DulnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
        builder: (locale) => MaterialApp(
              title: 'Dulno',
              theme: ThemeData(
                useMaterial3: true,
                primaryColor: Colors.black,
                colorScheme: ColorScheme.light(
                    primary: Color(0xFF2196F3), background: Color(0xFFE8E8E8)),
              ),
              home: HomePage(),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: Locales.delegates,
              supportedLocales: Locales.supportedLocales,
              locale: locale,
            ));
  }
}
