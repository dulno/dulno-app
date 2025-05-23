import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/alert/alert_loader.dart';
import 'package:dulno/config/google_options.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/profile/profile_sign_up_body.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileGoogleAlert {
  final Function signInCallback;

  ProfileGoogleAlert({required this.signInCallback});

  show(context) {
    GlobalKey<ProfileGoogleAlertContentState> contentKey =
        GlobalKey<ProfileGoogleAlertContentState>();
    GlobalKey<AlertState> alertKey = GlobalKey<AlertState>();
    var content = ProfileGoogleAlertContent(
      key: contentKey,
      alertKey: alertKey,
    );
    Alert(
      key: alertKey,
      icon: CupertinoIcons.exclamationmark_triangle,
      confirmButtonText: "alert.continue",
      content: content,
      confirmButtonEnabled: () {
        var state = contentKey.currentState;
        if (state == null) {
          return false;
        }
        return state.legalChecked;
      },
      callback: () {
        var state = contentKey.currentState;
        if (state == null) {
          return false;
        }
        processGoogleSignIn(
            context, state.legalChecked, state.newsletterChecked);
      },
    ).show(context);
  }

  Future<void> processGoogleSignIn(
      context, legalChecked, newsletterChecked) async {
    try {
      var googleSignIn = GoogleOptions.googleSignIn;
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
      AlertLoader().show(context);
      await sendInternalGoogleSignInRequest(
          context, idToken, legalChecked, newsletterChecked);
    } catch (exception) {
      Alert(
        description: "connection.failed",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
    }
  }

  Future<void> sendInternalGoogleSignInRequest(
      context, idToken, legalChecked, newsletterChecked) async {
    var body = <String, Object>{"token": idToken};
    body.addAll(
        await ProfileSignUpBody().generate(legalChecked, newsletterChecked));
    var response =
        await Request.post(url: "/user/bind/google/", body: body).send(context);
    Navigator.pop(context);
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
    await storeSignInResponse(responseBody);
    Alert(
      description: "product.profile.google.connect.success",
      icon: CupertinoIcons.check_mark_circled,
      callback: () {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductPage(),
          ),
          (route) => false,
        );
      },
    ).show(context);
    signInCallback();
  }

  Future<void> storeSignInResponse(responseBody) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "email", value: responseBody["email"]);
    if (responseBody["user"] != null &&
        responseBody["authenticationToken"] != null &&
        responseBody["refreshToken"] != null) {
      await storage.write(key: "user", value: responseBody["user"]);
      await storage.write(
          key: "authenticationToken",
          value: responseBody["authenticationToken"]);
      await storage.write(
          key: "refreshToken", value: responseBody["refreshToken"]);
    }
  }
}

class ProfileGoogleAlertContent extends StatefulWidget {
  GlobalKey<AlertState> alertKey;

  ProfileGoogleAlertContent({super.key, required this.alertKey});

  @override
  State<ProfileGoogleAlertContent> createState() =>
      ProfileGoogleAlertContentState();
}

class ProfileGoogleAlertContentState extends State<ProfileGoogleAlertContent> {
  bool legalChecked = false;
  bool newsletterChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Column(
        children: [
          CheckboxListTile(
            title: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                children: [
                  TextSpan(
                    text: Locales.string(context, "product.legal.compliant.1"),
                  ),
                  TextSpan(
                    text: Locales.string(
                        context, "product.legal.terms.of.service"),
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await launchUrl(
                            Uri.parse("https://dulno.com/terms-of-service/"));
                      },
                  ),
                  TextSpan(
                    text: Locales.string(context, "product.legal.compliant.2"),
                  ),
                  TextSpan(
                    text:
                        Locales.string(context, "product.legal.privacy.policy"),
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await launchUrl(
                            Uri.parse("https://dulno.com/privacy-policy/"));
                      },
                  ),
                  TextSpan(
                    text: Locales.string(context, "product.legal.compliant.3"),
                  ),
                ],
              ),
            ),
            value: legalChecked,
            onChanged: (bool? newValue) {
              widget.alertKey.currentState?.reload();
              setState(() {
                legalChecked = newValue!;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            // checkbox before text
            activeColor: Colors.indigo, // optional styling
          ),
          CheckboxListTile(
            title: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                children: [
                  TextSpan(
                    text: Locales.string(context, "product.legal.newsletter"),
                  ),
                ],
              ),
            ),
            value: newsletterChecked,
            onChanged: (bool? newValue) {
              setState(() {
                newsletterChecked = newValue!;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            // checkbox before text
            activeColor: Colors.indigo, // optional styling
          ),
        ],
      ),
    );
  }
}
