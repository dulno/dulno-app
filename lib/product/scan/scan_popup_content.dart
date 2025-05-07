import 'dart:convert';
import 'dart:io';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/scan/stamp_redemption.dart';
import 'package:flutter/cupertino.dart';
import 'package:nfc_manager/nfc_manager.dart';

abstract class ScanPopupContent extends StatefulWidget {
  final Function callback;
  final Function currentPageIndex;

  const ScanPopupContent(
      {super.key, required this.callback, required this.currentPageIndex});

  Future<void> readNFCTag(
      {required BuildContext context, Function? readCallback}) async {
    if (Platform.isAndroid) {
      NfcManager.instance.stopSession().catchError((_) {});
    }
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
    var redemptionResult = await redemption.redeemProcessed(context);
    if (!redemptionResult) {
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
    if (Platform.isAndroid) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {},
      );
    }
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
}
