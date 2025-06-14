import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:dulno/alert/alert.dart';
import 'package:dulno/alert/loader_alert.dart';
import 'package:dulno/config/environment_options.dart';
import 'package:dulno/notification/notification.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/coupon/coupon_cache.dart';
import 'package:dulno/product/profile/profile_language_state.dart';
import 'package:dulno/product/scan/scan_cache.dart';
import 'package:dulno/product/scan/scan_cooldown.dart';
import 'package:dulno/product/scan/scan_flashlight.dart';
import 'package:dulno/product/scan/stamp_redemption.dart';
import 'package:dulno/product/web/web_deep_link.dart';
import 'package:dulno/product/web/web_transmission.dart';
import 'package:dulno/request/request.dart';
import 'package:dulno/statistic/statistic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(["de", "en"]);
  if (!kIsWeb) {
    await DulnoNotification(navigatorKey: navigatorKey).setup();
  }
  runApp(DulnoApp());
}

class DulnoApp extends StatefulWidget {
  const DulnoApp({super.key});

  @override
  State<DulnoApp> createState() => _DulnoAppState();
}

class _DulnoAppState extends State<DulnoApp> with WidgetsBindingObserver {
  final GlobalKey<ProductPageState> _productPageKey =
      GlobalKey<ProductPageState>();
  final AppLinks _appLinks = AppLinks();
  bool _initialized = false;
  Uri? _deepLinkUri;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb && Platform.isAndroid) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {},
      );
    }
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
    ScanCache().redeem(navigatorKey.currentContext);
    CouponCache().redeem(navigatorKey.currentContext);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!kIsWeb) {
      DulnoStatistic().keep(context);
    }
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
                    primary: Color(0xFF2196F3), background: Color(0xFFE8E8E8)),
              ),
              home: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    checkInitialization(context);
                    processDeepLinkStamp(context, _productPageKey);
                    processDeepLinkTransmission(context, _productPageKey);
                  });
                  return ProductPage(key: _productPageKey);
                },
              ),
              debugShowCheckedModeBanner:
                  EnvironmentOptions.environment == DulnoEnvironment.staging,
              localizationsDelegates: Locales.delegates,
              supportedLocales: Locales.supportedLocales,
              locale: locale,
              navigatorKey: navigatorKey,
            ),
          ),
        );
      },
    );
  }

  Future<String> findLanguage() async {
    const storage = FlutterSecureStorage();
    final language = await storage.read(key: "language") ?? "de";
    return language;
  }

  void checkInitialization(context) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await checkAuthorization(context);
    await checkWebTransmission(context);
    processWebStamp(context, _productPageKey);
    ScanCache().redeem(context);
    CouponCache().redeem(context);
  }

  void processDeepLinkStamp(context, key) async {
    if (_deepLinkUri == null || !mounted) {
      return;
    }
    if (_deepLinkUri!.scheme != 'dulno' || _deepLinkUri!.host != 'stamp') {
      return;
    }
    if (await ScanCooldown().isActive()) {
      return;
    }
    String stamp = _deepLinkUri!.queryParameters['stamp'] ?? "";
    String picc = _deepLinkUri!.queryParameters['picc'] ?? "";
    String cmac = _deepLinkUri!.queryParameters['cmac'] ?? "";
    _deepLinkUri = null;
    if (stamp == "" || picc == "" || cmac == "") {
      Alert(
        description: "product.scan.error.nfc.tag",
        type: AlertType.error,
      ).show(context);
      return;
    }
    redeem(context, key, stamp, picc, cmac);
  }

  void processWebStamp(context, key) async {
    if (!kIsWeb || !mounted) {
      return;
    }
    html.Location location = html.window.location;
    String path = location.pathname ?? "";
    path = path.replaceAll(RegExp(r'\/+$'), '');
    if (path != "/stamp") {
      return;
    }
    if (await ScanCooldown().isActive()) {
      return;
    }
    Uri uri = Uri.parse(location.href);
    String stamp = uri.queryParameters['stamp'] ?? "";
    String picc = uri.queryParameters['picc'] ?? "";
    String cmac = uri.queryParameters['cmac'] ?? "";
    if (stamp == "" || picc == "" || cmac == "") {
      Alert(
        description: "product.scan.error.nfc.tag",
        type: AlertType.error,
      ).show(context);
      return;
    }
    redeem(context, key, stamp, picc, cmac);
  }

  void redeem(context, key, stamp, picc, cmac) {
    LoaderAlert().show(context);
    Future.delayed(
      Duration(milliseconds: 500),
      () async {
        var redemption = StampRedemption(stamp: stamp, picc: picc, cmac: cmac);
        var redemptionResult = await redemption.redeemProcessed(context);
        if (!redemptionResult) {
          return;
        }
        ScanCooldown().enable();
        if (!kIsWeb && Platform.isAndroid) {
          ScanFlashlight().flashlight();
        }
        if (key.currentState != null && key.currentState!.mounted) {
          key.currentState!.findCardListBody().reload();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
    );
  }

  Future<void> checkAuthorization(context) async {
    const storage = FlutterSecureStorage();
    var email = await storage.read(key: "email");
    if (email == null) {
      return;
    }
    await Request.get(url: "/user/authorized/").send(context);
  }

  Future<void> checkWebTransmission(context) async {
    if (!kIsWeb || !mounted) {
      return;
    }
    html.Location location = html.window.location;
    String path = location.pathname ?? "";
    path = path.replaceAll(RegExp(r'\/+$'), '');
    if (path != "/transmission") {
      return;
    }
    String? transmission = await WebTransmission().request(context);
    if (transmission == null) {
      return;
    }
    WebDeepLink(url: "dulno://transmission?id=$transmission").open();
  }

  void processDeepLinkTransmission(context, key) async {
    if (_deepLinkUri == null || !mounted) {
      return;
    }
    if (_deepLinkUri!.scheme != 'dulno' ||
        _deepLinkUri!.host != 'transmission') {
      return;
    }
    String transmission = _deepLinkUri!.queryParameters['id'] ?? "";
    _deepLinkUri = null;
    if (transmission == "") {
      return;
    }
    await WebTransmission().complete(context, transmission);
  }
}
