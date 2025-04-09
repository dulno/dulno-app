import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/profile/profile_email_connect_page.dart';
import 'package:dulno/product/profile/profile_language_state.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      serverClientId:
          "1057662416151-qt2uppuh1k3e6voe5d5gtpusck95oab1.apps.googleusercontent.com");
  Widget? accountContentElement;

  Future<void> _processGoogleSignIn() async {
    await _googleSignIn.signOut();
    final account = await _googleSignIn.signIn();
    if (account == null) {
      return;
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      return;
    }
    var body = <String, Object>{"token": idToken};
    var response =
        await Request.post(url: "/user/bind/google/", body: body).send();
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
      storage.write(key: "user", value: responseBody["user"]);
      storage.write(
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: LocaleText(
          "product.profile.title",
          style: TextStyle(fontFamily: "Arial"),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black12,
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30),
                      LocaleText(
                        "product.profile.account",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5),
                      accountContent(),
                      SizedBox(height: 30),
                      LocaleText(
                        "product.profile.language",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      _LanguageSelection(),
                      SizedBox(height: 30),
                      LocaleText(
                        "product.profile.notification",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      _NotificationToggle(),
                      Expanded(child: SizedBox()),
                      SizedBox(height: 50),
                      Divider(
                        color: Colors.grey[300],
                        height: 2,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 16.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children: [
                            _LinkText("product.profile.imprint",
                                "https://dulno.com/imprint/"),
                            _LinkText("product.profile.privacy.policy",
                                "https://dulno.com/privacy-policy/"),
                            _LinkText("product.profile.terms.of.service",
                                "https://dulno.com/terms-of-service/"),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, AsyncSnapshot<PackageInfo> package) {
                            return Text(
                              "Version ${package.data?.version ?? ""}",
                              style: TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      )
    );
  }

  Widget accountContent() {
    if (accountContentElement != null) {
      return accountContentElement!;
    }
    const storage = FlutterSecureStorage();
    return FutureBuilder<String?>(
      future: storage.read(key: "email"),
      builder: (context, AsyncSnapshot<String?> notifications) {
        if (notifications.connectionState == ConnectionState.done) {
          if (notifications.data != null && notifications.data != "") {
            accountContentElement = accountConnectedContent(notifications.data);
          } else {
            accountContentElement = accountConnectContent();
          }
          return accountContentElement!;
        }
        return Skeletonizer(
          enabled: notifications.connectionState != ConnectionState.done,
          child: Skeleton.leaf(
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget accountConnectedContent(email) {
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
                "product.profile.account.email.headline",
                style: TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 5),
              Text(
                email,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                      alignment: Alignment.center),
                  onPressed: () async {
                    const storage = FlutterSecureStorage();
                    await storage.delete(key: "email");
                    await _googleSignIn.signOut();
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              ProfilePage(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero),
                    );
                  },
                  icon: Container(
                    margin: EdgeInsets.only(right: 2),
                    child: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LocaleText(
                        "product.profile.logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget accountConnectContent() {
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
              await _processGoogleSignIn();
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

class _LanguageSelection extends StatelessWidget {
  _LanguageSelection({super.key});

  @override
  Widget build(BuildContext context) {
    var languageState = Provider.of<ProfileLanguageState>(context);
    return Container(
      alignment: Alignment.center,
      child: OverflowBar(
        alignment: MainAxisAlignment.spaceEvenly,
        overflowAlignment: OverflowBarAlignment.center,
        children: [
          createLanguageButton(languageState, "assets/images/languages/en.webp",
              "en", languageState.getLanguage == "en", context),
          createLanguageButton(languageState, "assets/images/languages/de.webp",
              "de", languageState.getLanguage == "de", context)
        ],
      ),
    );
  }

  createLanguageButton(languageState, flag, language, selected, context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: selected ? Colors.indigo[50] : Colors.white,
          padding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
              side: BorderSide(
                  color: selected
                      ? Colors.indigo[100] ?? Colors.indigo
                      : Colors.grey[300] ?? Colors.grey,
                  width: selected ? 2 : 1)),
        ),
        onPressed: () async {
          changeLanguage(languageState, language);
          await Locales.change(context, language);
        },
        child: Container(
          width: 130,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: AssetImage(flag),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  changeLanguage(languageState, language) async {
    languageState.setLanguage(language);
    const storage = FlutterSecureStorage();
    await storage.write(key: "language", value: language);
  }
}

class _NotificationToggle extends StatefulWidget {
  const _NotificationToggle({super.key});

  @override
  State<_NotificationToggle> createState() => _NotificationToggleState();
}

class _NotificationToggleState extends State<_NotificationToggle> {
  bool _notificationsEnabled = true;

  void _toggleNotifications(bool value) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "notifications", value: value.toString());
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    return FutureBuilder<String?>(
      future: storage.read(key: "notifications"),
      builder: (context, AsyncSnapshot<String?> notifications) {
        if (notifications.connectionState == ConnectionState.done) {
          _notificationsEnabled = notifications.data != "false";
        }
        return Skeletonizer(
          enabled: notifications.connectionState != ConnectionState.done,
          child: SwitchListTile(
            title: LocaleText("product.profile.notification.description"),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            activeColor: Colors.indigo,
            inactiveThumbColor: Colors.grey,
          ),
        );
      },
    );
  }
}

class _LinkText extends StatelessWidget {
  final String text;
  final String url;

  const _LinkText(this.text, this.url);

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
