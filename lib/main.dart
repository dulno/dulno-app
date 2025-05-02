import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:dulno/notification/notification.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/scan/scan_cache.dart';
import 'package:dulno/product/profile/profile_language_state.dart';
import 'package:dulno/product/scan/scan_popup.dart';
import 'package:dulno/product/scan/scan_popup_content.dart';
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
    ScanCache().redeem(navigatorKey.currentContext);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder<void>(
      future: ScanCache().redeem(context),
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

  void processDeepLink(context) {
    if (_deepLinkUri == null || !mounted) {
      return;
    }
    if (_deepLinkUri!.scheme != 'dulno' || _deepLinkUri!.host != 'stamp') {
      return;
    }
    String stamp = _deepLinkUri!.queryParameters['stamp'] ?? "";
    String picc = _deepLinkUri!.queryParameters['picc'] ?? "";
    String cmac = _deepLinkUri!.queryParameters['cmac'] ?? "";
    _deepLinkUri = null;
    GlobalKey<ScanPopupContentState> key = GlobalKey<ScanPopupContentState>();
    ScanPopup(
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
