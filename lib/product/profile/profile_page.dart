import 'package:dulno/product/profile/profile_email_connect_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;

  Future<void> _handleSignIn() async {
    final user = await _googleSignIn.signIn();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
    });
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
        title: LocaleText("product.profile.title"),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              LocaleText(
                "product.profile.account",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
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
                    await _handleSignIn();
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
              ),
              SizedBox(height: 30),
              LocaleText(
                "product.profile.language",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 50),
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
            ],
          ),
        ),
      ),
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
