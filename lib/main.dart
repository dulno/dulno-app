import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dulno/alert/alert.dart';
import 'package:dulno/config/firebase_options.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/profile/profile_language_state.dart';
import 'package:dulno/request/request.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class DulnoApp extends StatefulWidget {
  const DulnoApp({super.key});

  @override
  State<DulnoApp> createState() => _DulnoAppState();
}

class _DulnoAppState extends State<DulnoApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) {
      return;
    }
    checkAppIntegrity();
  }

  Future<void> checkAppIntegrity() async {
    await checkUserCreation();
    await checkStampRedemption(navigatorKey.currentContext);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder<void>(
      future: checkUserCreation(),
      builder: (context, AsyncSnapshot<void> userCreationSnapshot) {
        return FutureBuilder<void>(
            future: checkStampRedemption(context),
            builder: (context, AsyncSnapshot<void> redemptionSnapshot) {
              return FutureBuilder<String>(
                future: findLanguage(),
                builder: (context, AsyncSnapshot<String> languageSnapshot) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                          create: (_) => ProfileLanguageState(
                              languageSnapshot.data ?? "de")),
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
                        navigatorKey: navigatorKey,
                      ),
                    ),
                  );
                },
              );
            });
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
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return;
    }
    await storage.write(key: "user", value: responseBody["id"]);
    await storage.write(
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

  Future<void> checkStampRedemption(context) async {
    const storage = FlutterSecureStorage();
    final scanCache = await storage.read(key: "scan_cache");
    if (scanCache == null) {
      return;
    }
    var scans = jsonDecode(scanCache);
    if (scans.isEmpty) {
      return;
    }
    var remainingScans = [];
    var failedResults = 0;
    for (var scan in scans) {
      var redemptionResult =
          await redeemStamp(scan["stamp"], scan["picc"], scan["cmac"]);
      if (redemptionResult == 0) {
        remainingScans.add(scan);
      } else if (redemptionResult == 1) {
        failedResults++;
      }
    }
    await storage.write(key: "scan_cache", value: jsonEncode(remainingScans));
    if (remainingScans.isEmpty) {
      Alert(
        description: "scan.redemption.successful",
        icon: CupertinoIcons.check_mark_circled,
      ).show(context);
    } else if (failedResults > 0) {
      Alert(
        description: "scan.redemption.failed",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
    }
  }

  Future<int> redeemStamp(stamp, picc, cmac) async {
    var body = <String, Object>{"stamp": stamp, "picc": picc, "cmac": cmac};
    var response = await Request.post(url: "/user/stamp/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return 0;
    }
    var responseBody = jsonDecode(response.body);
    return !responseBody["success"] ? 1 : 2;
  }
}
