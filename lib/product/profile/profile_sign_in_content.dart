import 'package:dulno/product/profile/profile_email_connect_page.dart';
import 'package:dulno/product/profile/profile_google_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileSignInContent extends StatelessWidget {
  final Function signInCallback;

  const ProfileSignInContent({super.key, required this.signInCallback});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocaleText(
                "product.profile.account.disclaimer.headline",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 5),
              LocaleText(
                "product.profile.account.disclaimer.description",
                style: TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.indigo),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                padding: WidgetStateProperty.all(EdgeInsets.all(15)),
                alignment: Alignment.centerLeft),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileEmailConnectPage(
                          signInCallback: signInCallback,
                        )),
              );
            },
            icon: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: FaIcon(
                FontAwesomeIcons.envelope,
                color: Colors.white,
                size: 25,
              ),
            ),
            label: LocaleText(
              "product.profile.account.email.button",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.black),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                padding: WidgetStateProperty.all(EdgeInsets.all(15)),
                alignment: Alignment.centerLeft),
            onPressed: () async {
              ProfileGoogleAlert(signInCallback: signInCallback).show(context);
            },
            icon: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: FaIcon(
                FontAwesomeIcons.google,
                color: Colors.white,
                size: 25,
              ),
            ),
            label: LocaleText(
              "product.profile.account.google.button",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        )
      ],
    );
  }
}
