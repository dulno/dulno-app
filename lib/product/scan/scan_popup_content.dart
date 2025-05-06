import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/scan/stamp_redemption.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nfc_manager/nfc_manager.dart';

abstract class ScanPopupContent extends StatefulWidget {
  final Function callback;
  final Function currentPageIndex;

  const ScanPopupContent(
      {super.key, required this.callback, required this.currentPageIndex});

  Future<void> readNFCTag(
      {required BuildContext context, Function? readCallback}) async {
    NfcManager.instance.startSession(
      invalidateAfterFirstRead: true,
      onDiscovered: (NfcTag tag) async {
        if (readCallback != null) {
          readCallback();
        }
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
        if (error.type == NfcErrorType.userCanceled) {
          return;
        }
        displayNFCTagScanError(context);
      },
    );
  }

  void displayNFCTagScanError(context) {
    Navigator.pop(context);
    Alert(
      description: "product.scan.error.scan",
      icon: CupertinoIcons.exclamationmark_triangle,
    ).show(context);
  }

  void displayNFCTagUnsupportedError(context) {
    Navigator.pop(context);
    Alert(
      description: "product.scan.unsupported.description",
      icon: CupertinoIcons.exclamationmark_triangle,
    ).show(context);
  }

  Future<void> processNFCTagScan(context, payloadString) async {
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
      displayScanError(context, redemption.responseBody["error"]);
      return;
    }
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

abstract class ScanPopupContentState<T extends ScanPopupContent>
    extends State<T> with WidgetsBindingObserver {
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
    NfcManager.instance.stopSession().catchError((_) {});
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkNFC(context);
      });
    }
  }

  Future<void> checkNFC(context);

  Future<void> externalStampRedemption(context, stamp, picc, cmac) async {
    if (stamp == "" || picc == "" || cmac == "") {
      Navigator.pop(context);
      Alert(
        description: "product.scan.error.nfc.tag",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
      return;
    }
    await widget.redeemStamp(context, stamp, picc, cmac);
  }
}
