import 'package:app_settings/app_settings.dart';
import 'package:dulno/product/scan/scan_popup_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class AndroidScanPopupContent extends ScanPopupContent {
  const AndroidScanPopupContent(
      {super.key, required super.callback, required super.currentPageIndex});

  @override
  State<AndroidScanPopupContent> createState() =>
      AndroidScanPopupContentState();
}

class AndroidScanPopupContentState
    extends ScanPopupContentState<AndroidScanPopupContent> {
  bool nfcSupported = true;
  bool scanned = false;

  @override
  Future<void> checkNFC(context) async {
    NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
    if (availability == NFCAvailability.disabled) {
      await AppSettings.openAppSettings(type: AppSettingsType.nfc);
    } else if (availability == NFCAvailability.not_supported) {
      setState(() {
        nfcSupported = false;
      });
    } else {
      widget.readNFCTag(
        context: context,
        readCallback: () {
          setState(
            () {
              scanned = true;
            },
          );
        },
      );
    }
  }

  @override
  Future<void> externalStampRedemption(context, stamp, picc, cmac) async {
    setState(() {
      scanned = true;
    });
    await super.externalStampRedemption(context, stamp, picc, cmac);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
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
      ),
    );
  }
}
