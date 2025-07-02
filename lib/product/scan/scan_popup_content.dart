import 'dart:io';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/scan/scan_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

abstract class ScanPopupContent extends StatefulWidget {
  final Function callback;

  const ScanPopupContent({super.key, required this.callback});
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
    if (!kIsWeb && !Platform.isAndroid) {
      NfcManager.instance.stopSession().catchError((_) {});
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

  Future<void> readNFCTag(
      {required BuildContext context, Function? readCallback}) async {
    ScanSession session = ScanSession(callback: widget.callback);
    session.readNFCTag(context: context, readCallback: readCallback);
  }

  void displayNFCTagUnsupportedError(context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Alert(
      description: "product.scan.unsupported.description",
      type: AlertType.error,
    ).show(context);
  }
}
