import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:dulno/alert/alert.dart';
import 'package:dulno/notification/notification.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/base/scan_popup.dart';
import 'package:dulno/product/profile/profile_language_state.dart';
import 'package:dulno/request/request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(["de", "en"]);
  await DulnoNotification(navigatorKey: navigatorKey).setup();
  runApp(DulnoApp());
}

class DulnoApp extends StatefulWidget {
  const DulnoApp({super.key});

  @override
  State<DulnoApp> createState() => _DulnoAppState();
}

class _DulnoAppState extends State<DulnoApp> with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  Uri? _deepLinkUri;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    final Uri? initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) async {
    setState(() {
      _deepLinkUri = uri;
    });
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
                  home: Builder(
                    builder: (context) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        processDeepLink(context);
                      });
                      return ProductPage();
                    },
                  ),
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
        callback: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
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
      body["language"] = await storage.read(key: "language") ?? "de";
    }
    var response = await Request.post(url: "/user/stamp/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return 0;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return 1;
    }
    updateCardCache(responseBody);
    return 2;
  }

  Future<void> updateCardCache(responseBody) async {
    const storage = FlutterSecureStorage();
    final cardCache = await storage.read(key: "cards");
    var cards = cardCache == null ? [] : jsonDecode(cardCache);
    var action = responseBody["action"];
    responseBody.remove("success");
    responseBody.remove("action");
    if (action == "CREATE") {
      cards.add(responseBody);
    } else {
      cards.removeWhere((card) => card["itemId"] == responseBody["itemId"]);
      if (action == "UPDATE") {
        cards.add(responseBody);
      }
    }
    await storage.write(key: "cards", value: jsonEncode(cards));
    FirebaseMessaging.instance.subscribeToTopic(responseBody["partnerId"]);
  }

  void processDeepLink(context) {
    if (_deepLinkUri == null || !mounted) {
      return;
    }
    String stamp = _deepLinkUri!.queryParameters['stamp'] ?? "";
    String picc = _deepLinkUri!.queryParameters['picc'] ?? "";
    String cmac = _deepLinkUri!.queryParameters['cmac'] ?? "";
    _deepLinkUri = null;
    GlobalKey<ProductNFCScanPopupContentState> key =
        GlobalKey<ProductNFCScanPopupContentState>();
    ProductNFCScanPopup(
      callback: () {},
      currentPageIndex: () => -1,
    ).show(context, key);
    Future.delayed(Duration(milliseconds: 500), () {
      if (key.currentState != null && key.currentState!.mounted) {
        key.currentState!.externalStampRedemption(context, stamp, picc, cmac);
      }
    });
  }
}
