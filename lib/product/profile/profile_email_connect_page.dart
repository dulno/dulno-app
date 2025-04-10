import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/profile/profile_email_code_page.dart';
import 'package:dulno/product/profile/profile_page.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileEmailConnectPage extends StatefulWidget {
  const ProfileEmailConnectPage({super.key});

  @override
  State<ProfileEmailConnectPage> createState() =>
      _ProfileEmailConnectPageState();
}

class _ProfileEmailConnectPageState extends State<ProfileEmailConnectPage> {
  final TextEditingController _controller = TextEditingController();
  bool _newsletterChecked = false;
  bool _isEmailValid = false;
  bool _hasTyped = false;
  bool _connecting = false;

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
                "product.profile.email.connect.headline",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                onChanged: _checkEmail,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  hintText: Locales.string(
                    context,
                    "product.profile.email.connect.placeholder",
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    size: 25,
                  ),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: _buildInputBorder(),
                  enabledBorder: _buildInputBorder(),
                  focusedBorder: _buildInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              CheckboxListTile(
                title: LocaleText(
                  "product.profile.email.connect.newsletter",
                  style: TextStyle(fontSize: 12),
                ),
                value: _newsletterChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _newsletterChecked = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                // checkbox before text
                activeColor: Colors.indigo, // optional styling
              ),
              SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          _isEmailValid ? Colors.indigo : Colors.indigo[200]),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      alignment: Alignment.center),
                  onPressed: _isEmailValid
                      ? () {
                          requestBinding(context);
                        }
                      : null,
                  icon: Container(
                    margin: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.login,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LocaleText(
                        "product.profile.email.connect.button",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      _connecting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void requestBinding(context) async {
    setState(() {
      _connecting = true;
    });
    var body = <String, Object>{
      "email": _controller.text,
      "newsletter": _newsletterChecked
    };
    var response =
        await Request.post(url: "/user/bind/request/", body: body).send();
    setState(() {
      _connecting = false;
    });
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
        description: "product.profile.email.connect.failure.email.format",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
      return;
    }
    displayBindingCodePage(context);
  }

  void displayBindingCodePage(context) {
    var codeController = TextEditingController();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEmailCodePage(
          controller: codeController,
          email: _controller.text,
          callback: (code) async {
            completeBinding(context, codeController, code);
          },
        ),
      ),
    );
  }

  void completeBinding(context, codeController, code) async {
    var body = <String, Object>{"code": code};
    var response =
        await Request.post(url: "/user/bind/complete/", body: body).send();
    if (response == null || response.statusCode == 409) {
      Alert(
        description: "connection.failed",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      codeController.text = "";
      Alert(
              description: "product.profile.email.connect.failure.complete",
              icon: CupertinoIcons.exclamationmark_triangle)
          .show(context);
      return;
    }
    const storage = FlutterSecureStorage();
    await storage.write(key: "email", value: _controller.text);
    if (responseBody["user"] != null && responseBody["authenticationKey"] != null) {
      await storage.write(key: "user", value: responseBody["user"]);
      await storage.write(
          key: "authenticationKey", value: responseBody["authenticationKey"]);
    }
    Alert(
      description: "product.profile.email.connect.success",
      icon: CupertinoIcons.check_mark_circled,
      callback: () {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
            transitionDuration: Duration.zero
          ),
          ModalRoute.withName('/'),
        );
      },
    ).show(context);
  }

  void _checkEmail(String value) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final isValid = emailRegExp.hasMatch(value);
    setState(() {
      _hasTyped = true;
      _isEmailValid = isValid;
    });
  }

  OutlineInputBorder _buildInputBorder() {
    Color borderColor;
    if (!_hasTyped) {
      borderColor = Colors.grey;
    } else {
      borderColor = _isEmailValid ? Colors.green : Colors.red;
    }
    return OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 2.0),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
