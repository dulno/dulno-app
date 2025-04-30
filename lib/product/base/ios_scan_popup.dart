import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/base/stamp_redemption.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ProductIOSNFCScanPopup {
  Function callback;
  Function currentPageIndex;

  ProductIOSNFCScanPopup(
      {required this.callback, required this.currentPageIndex});

  show(BuildContext context, Key? key) {
    readNFCTag(context);
  }

  Future<void> externalStampRedemption(context, stamp, picc, cmac) async {
    if (stamp == "" || picc == "" || cmac == "") {
      Alert(
        description: "product.scan.error.nfc.tag",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
      return;
    }
    await redeemStamp(context, stamp, picc, cmac);
  }

  Future<void> readNFCTag(context) async {
    if (await NfcManager.instance.isAvailable()) {
      NfcManager.instance.startSession(
          invalidateAfterFirstRead: true,
          onDiscovered: (NfcTag tag) async {
            NfcManager.instance.stopSession();
            try {
              var payloadBytes =
                  tag.data["ndef"]["cachedMessage"]["records"][0]["payload"];
              var payloadString = utf8.decode(payloadBytes.sublist(1));
              processNFCTagScan(context, payloadString);
            } catch (exception) {
              displayNFCTagScanError(context);
            }
          },
          onError: (NfcError error) async {
            displayNFCTagScanError(context);
          }
      );
    } else {
      displayNFCTagScanError(context);
    }
  }

  void displayNFCTagScanError(context) {
    Alert(
      description: "product.scan.error.scan",
      icon: CupertinoIcons.exclamationmark_triangle,
    ).show(context);
  }

  Future<void> processNFCTagScan(context, payloadString) async {
    Uri uri = Uri.parse(payloadString);
    String stamp = uri.queryParameters['stamp'] ?? "";
    String picc = uri.queryParameters['picc'] ?? "";
    String cmac = uri.queryParameters['cmac'] ?? "";
    if (stamp == "" || picc == "" || cmac == "") {
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
      displayScanError(context, redemption.responseBody["error"]);
      return;
    }
    if (currentPageIndex() == 0) {
      callback();
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
    Alert(
      description: "product.scan.connection.cache",
      icon: CupertinoIcons.antenna_radiowaves_left_right,
    ).show(context);
  }

  void displayScanError(context, error) {
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
}
