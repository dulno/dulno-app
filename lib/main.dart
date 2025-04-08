import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dulno/config/firebase_options.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/profile/profile_language_state.dart';
import 'package:dulno/request/request.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var data = message.data;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(["de", "en"]);
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
    return FutureBuilder<void>(
      future: checkUserCreation(),
      builder: (context, AsyncSnapshot<void> snapshot) {
        return FutureBuilder<String>(
          future: findLanguage(),
          builder: (context, AsyncSnapshot<String> languageSnapshot) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (_) =>
                        ProfileLanguageState(languageSnapshot.data ?? "de")),
              ],
              child: LocaleBuilder(
                builder: (locale) => MaterialApp(
                  title: 'Dulno',
                  theme: ThemeData(
                    useMaterial3: true,
                    primaryColor: Colors.black,
                    colorScheme: ColorScheme.light(
                        primary: Color(0xFF2196F3),
                        background: Color(0xFFE8E8E8)),
                  ),
                  home: ProductPage(),
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: Locales.delegates,
                  supportedLocales: Locales.supportedLocales,
                  locale: locale,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> checkUserCreation() async {
    const storage = FlutterSecureStorage();
    final user = await storage.read(key: "user") ?? "";
    final authenticationKey =
        await storage.read(key: "authenticationKey") ?? "";
    if (user != "" && authenticationKey != "") {
      return;
    }
    var language = ui.PlatformDispatcher.instance.locale.languageCode;
    var body = <String, Object>{
      "language": language,
      "legalAccepted": true,
      "firebaseIdentifier": await findFirebaseToken()
    };
    body.addAll(await findDeviceInfo());
    var response = await Request.post(url: "/user/signup/", body: body).send();
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return;
    }
    storage.write(key: "user", value: responseBody["id"]);
    storage.write(
        key: "authenticationKey", value: responseBody["authenticationKey"]);
  }

  Future<Map<String, String>> findDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "id": await const AndroidId().getId() ?? "",
        "operatingSystem": "Android",
        "operatingSystemVersion": androidInfo.version.release ?? "",
        "brand": androidInfo.brand ?? "",
        "model": androidInfo.model ?? "",
        "name": androidInfo.device ?? "",
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "id": iosInfo.identifierForVendor ?? "",
        "operatingSystem": "IOS",
        "operatingSystemVersion": iosInfo.systemVersion ?? "",
        "brand": "Apple",
        "model": iosInfo.utsname.machine ?? "",
        "name": iosInfo.name ?? "",
      };
    }
    return {};
  }

  Future<String> findFirebaseToken() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    var instance = FirebaseMessaging.instance;
    await instance.requestPermission();
    var token = await instance.getToken();
    return token ?? "";
  }

  Future<String> findLanguage() async {
    const storage = FlutterSecureStorage();
    final language = await storage.read(key: "language") ?? "de";
    return language;
  }
}
