import 'package:dulno/product/profile/profile_sign_in_content.dart';
import 'package:dulno/product/profile/profile_account_content.dart';
import 'package:dulno/product/profile/profile_footer_link.dart';
import 'package:dulno/product/profile/profile_language_selection.dart';
import 'package:dulno/product/profile/profile_notification_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 5),
                        accountContent(),
                        SizedBox(height: 30),
                        LocaleText(
                          "product.profile.language",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        ProfileLanguageSelection(),
                        SizedBox(height: 30),
                        LocaleText(
                          "product.profile.notification",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        ProfileNotificationToggle(),
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
                              ProfileFooterLink("product.profile.imprint",
                                  "https://dulno.com/imprint/"),
                              ProfileFooterLink(
                                  "product.profile.privacy.policy",
                                  "https://dulno.com/privacy-policy/"),
                              ProfileFooterLink(
                                  "product.profile.terms.of.service",
                                  "https://dulno.com/terms-of-service/"),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder:
                                (context, AsyncSnapshot<PackageInfo> package) {
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
        ));
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
            accountContentElement = ProfileAccountContent(
                googleSignIn: _googleSignIn, email: notifications.data ?? "");
          } else {
            accountContentElement =
                ProfileSignInContent(googleSignIn: _googleSignIn);
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
}
