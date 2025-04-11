import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileFooterLink extends StatelessWidget {
  final String text;
  final String url;

  const ProfileFooterLink(this.text, this.url);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await launchUrl(Uri.parse(url));
      },
      child: LocaleText(
        text,
        style: TextStyle(
          color: Colors.black,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}