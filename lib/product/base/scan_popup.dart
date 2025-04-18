import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/base/stamp_redemption.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductNFCScanPopup {
  Function callback;
  Function currentPageIndex;

  ProductNFCScanPopup({required this.callback, required this.currentPageIndex});

  show(BuildContext context, Key? key) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close when tapping outside
          },
          behavior: HitTestBehavior.opaque,
          // Ensures tap detection outside the child
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              // Prevents closing when tapping inside
              behavior: HitTestBehavior.translucent,
              // Ensures touch events inside are not blocked
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                margin: EdgeInsets.only(bottom: 30),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ProductNFCScanPopupContent(
                  key: key,
                  callback: callback,
                  currentPageIndex: currentPageIndex,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProductNFCScanPopupContent extends StatefulWidget {
  Function callback;
  Function currentPageIndex;

  ProductNFCScanPopupContent(
      {super.key, required this.callback, required this.currentPageIndex});

  @override
  State<ProductNFCScanPopupContent> createState() =>
      ProductNFCScanPopupContentState();
}

class ProductNFCScanPopupContentState extends State<ProductNFCScanPopupContent>
    with WidgetsBindingObserver {
  bool nfcSupported = true;
  bool scanned = false;

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

  Future<void> externalStampRedemption(context, stamp, picc, cmac) async {
    setState(() {
      scanned = true;
    });
    if (stamp == "" || picc == "" || cmac == "") {
      Navigator.pop(context);
      Alert(
        description: "product.scan.error.nfc.tag",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
      return;
    }
    await redeemStamp(context, stamp, picc, cmac);
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
        processNFCTagScan(payloadString);
      } else {
        displayNFCTagScanError(context);
      }
    } else {
      displayNFCTagScanError(context);
    }
  }

  void displayNFCTagScanError(context) {
    Navigator.pop(context);
    Alert(
      description: "product.scan.error.scan",
      icon: CupertinoIcons.exclamationmark_triangle,
    ).show(context);
  }

  Future<void> processNFCTagScan(payloadString) async {
    Uri uri = Uri.parse(payloadString);
    String stamp = uri.queryParameters['stamp'] ?? "";
    String picc = uri.queryParameters['picc'] ?? "";
    String cmac = uri.queryParameters['cmac'] ?? "";
    if (stamp == "" || picc == "" || cmac == "") {
      Navigator.pop(context);
      Alert(
        description: "product.scan.error.nfc.tag",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
      return;
    }
    await redeemStamp(context, stamp, picc, cmac);
  }

  Future<void> redeemStamp(context, stamp, picc, cmac) async {
    var redemption = StampRedemption(stamp: stamp, picc: picc, cmac: cmac);
    var redemptionResult = await redemption.redeem();
    if (redemptionResult == 0) {
      processRedemptionUnconnected(context, stamp, picc, cmac);
      return;
    }
    if (redemptionResult == 1) {
      Navigator.pop(context);
      displayScanError(redemption.responseBody["error"]);
      return;
    }
    if (widget.currentPageIndex() == 0) {
      widget.callback();
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

  Future<void> processRedemptionUnconnected(context, stamp, picc, cmac) async {
    var scan = <String, Object>{"stamp": stamp, "picc": picc, "cmac": cmac};
    const storage = FlutterSecureStorage();
    final scanCache = await storage.read(key: "scans");
    var scans = scanCache == null ? [] : jsonDecode(scanCache);
    scans.add(scan);
    await storage.write(key: "scans", value: jsonEncode(scans));
    Navigator.pop(context);
    Alert(
      description: "product.scan.connection.cache",
      icon: CupertinoIcons.antenna_radiowaves_left_right,
    ).show(context);
  }

  void displayScanError(error) {
    var description = "";
    if (error == 1000) {
      description = "product.scan.error.stamp.existence";
    } else if (error == 1001) {
      description = "product.scan.error.stamp.state";
    } else if (error == 1002 || error == 1003) {
      description = "product.scan.error.scan.validation";
    } else if (error == 1004) {
      description = "product.scan.error.already.scanned";
    } else if (error == 1005) {
      description = "product.scan.error.card.existence";
    } else if (error == 1006) {
      description = "product.scan.error.value.absent";
    } else if (error == 1007) {
      description = "product.scan.error.member.absent";
    } else if (error == 1008) {
      description = "product.scan.error.already.member";
    }
    Alert(
      description: description,
      icon: CupertinoIcons.exclamationmark_triangle,
    ).show(context);
    return;
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
              return scanned
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 25),
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 50.0,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 45.0,
                        child: Image.asset('assets/images/android-nfc.png',
                            width: 75),
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
