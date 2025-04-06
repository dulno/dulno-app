import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class ProductNFCScanPopup extends StatefulWidget {
  Function callback;
  Function currentPageIndex;

  ProductNFCScanPopup(
      {super.key, required this.callback, required this.currentPageIndex});

  @override
  State<ProductNFCScanPopup> createState() => _ProductNFCScanPopupState(
      callback: callback, currentPageIndex: currentPageIndex);
}

class _ProductNFCScanPopupState extends State<ProductNFCScanPopup>
    with WidgetsBindingObserver {
  Function callback;
  Function currentPageIndex;
  bool nfcSupported = true;
  bool scanned = false;

  _ProductNFCScanPopupState(
      {required this.callback, required this.currentPageIndex});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkNFC(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> checkNFC(context) async {
    NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
    if (availability == NFCAvailability.disabled) {
      await AppSettings.openAppSettings(type: AppSettingsType.nfc);
    } else if (availability == NFCAvailability.not_supported) {
      setState(() {
        nfcSupported = false;
      });
    } else {
      readNFCTag(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkNFC(context);
      });
    }
  }

  Future<void> readNFCTag(context) async {
    var tag = await FlutterNfcKit.poll();
    setState(() {
      scanned = true;
    });
    if (tag.ndefAvailable == true) {
      var records = await FlutterNfcKit.readNDEFRecords();
      if (records.isNotEmpty) {
        var payloadBytes = records[0].payload ?? <int>[];
        var payloadString = utf8.decode(payloadBytes.sublist(1));
        Uri uri = Uri.parse(payloadString);
        String stamp = uri.queryParameters['stamp'] ?? "";
        String picc = uri.queryParameters['picc'] ?? "";
        String cmac = uri.queryParameters['cmac'] ?? "";
        var body = <String, Object>{"stamp": stamp, "picc": picc, "cmac": cmac};
        var response =
            await Request.post(url: "/user/stamp/", body: body).send();
        var responseBody = jsonDecode(response.body);
        if (currentPageIndex() == 0) {
          callback();
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocaleText(
            nfcSupported
                ? 'product.scan.popup.title'
                : 'product.scan.unsupported.title',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Builder(
            builder: (context) {
              if (!nfcSupported) {
                return Container();
              }
              return CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 50.0,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 45.0,
                  child: scanned
                      ? CircularProgressIndicator()
                      : Image.asset('assets/images/android-nfc.png', width: 75),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          LocaleText(
            nfcSupported
                ? 'product.scan.popup.description'
                : 'product.scan.unsupported.description',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: LocaleText('product.scan.popup.cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
