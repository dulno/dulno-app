import 'dart:async';
import 'dart:convert';

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
  FirebaseMessaging.instance.subscribeToTopic("dulno");
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
    checkStampRedemption(navigatorKey.currentContext);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder<void>(
      future: checkStampRedemption(context),
      builder: (context, AsyncSnapshot<void> redemptionSnapshot) {
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
                  navigatorKey: navigatorKey,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> findLanguage() async {
    const storage = FlutterSecureStorage();
    final language = await storage.read(key: "language") ?? "de";
    return language;
  }

  Future<void> checkStampRedemption(context) async {
    const storage = FlutterSecureStorage();
    final scanCache = await storage.read(key: "scans");
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
    await storage.write(key: "scans", value: jsonEncode(remainingScans));
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
    const storage = FlutterSecureStorage();
    var body = <String, Object>{"stamp": stamp, "picc": picc, "cmac": cmac};
    if (await storage.read(key: "user") == null) {
      final cardCache = await storage.read(key: "cards");
      var cards = (cardCache == null ? [] : jsonDecode(cardCache))
          .map((card) => card["itemId"])
          .toList();
      body["cards"] = cards;
    }
    var response = await Request.post(url: "/user/stamp/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return 0;
    }
    var responseBody = jsonDecode(response.body);
    return !responseBody["success"] ? 1 : 2;
  }
}
