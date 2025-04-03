import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class NFCScanPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocaleText(
              'product.scan.popup.title',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 50.0,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 45.0,
                child: Image.asset('assets/images/android-nfc.png', width: 75),
              ),
            ),
            SizedBox(height: 20),
            LocaleText(
              'product.scan.popup.description',
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
        ));
  }
}
