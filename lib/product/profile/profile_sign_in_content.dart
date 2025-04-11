import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/profile/profile_email_connect_page.dart';
import 'package:dulno/product/profile/profile_page.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileSignInContent extends StatelessWidget {
  final GoogleSignIn googleSignIn;

  const ProfileSignInContent({super.key, required this.googleSignIn});

  Future<void> _processGoogleSignIn(context) async {
    try {
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        return;
      }
      await sendInternalGoogleSignInRequest(context, idToken);
    } catch (exception) {
      Alert(
        description: "connection.failed",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
    }
  }

  Future<void> sendInternalGoogleSignInRequest(context, idToken) async {
    var body = <String, Object>{"token": idToken};
    var response =
        await Request.post(url: "/user/bind/google/", body: body).send();
    if (response == null || response.statusCode == 409) {
      Alert(
        description: "connection.failed",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      Alert(
        description: "product.profile.google.connect.failure",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
      return;
    }
    completeGoogleSignIn(context, responseBody);
  }

  void completeGoogleSignIn(context, responseBody) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "email", value: responseBody["email"]);
    if (responseBody["user"] != null &&
        responseBody["authenticationKey"] != null) {
      await storage.write(key: "user", value: responseBody["user"]);
      await storage.write(
          key: "authenticationKey", value: responseBody["authenticationKey"]);
    }
    Alert(
      description: "product.profile.google.connect.success",
      icon: CupertinoIcons.check_mark_circled,
      callback: () {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProfilePage(),
              transitionDuration: Duration.zero),
          ModalRoute.withName('/'),
        );
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: Colors.grey[300] ?? Colors.grey,
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
                    builder: (context) => ProfileEmailConnectPage()),
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
              await _processGoogleSignIn(context);
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
