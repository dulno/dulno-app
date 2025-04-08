import 'dart:convert';

import 'package:dulno/product/profile/profile_email_code_page.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ProfileEmailConnectPage extends StatefulWidget {
  const ProfileEmailConnectPage({super.key});

  @override
  State<ProfileEmailConnectPage> createState() =>
      _ProfileEmailConnectPageState();
}

class _ProfileEmailConnectPageState extends State<ProfileEmailConnectPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isEmailValid = false;
  bool _hasTyped = false;

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
              SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          _isEmailValid ? Colors.blue : Colors.blue[200]),
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
                  label: LocaleText(
                    "product.profile.email.connect.button",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void requestBinding(context) async {
    var body = <String, Object>{"email": _controller.text, "newsletter": true};
    var response =
        await Request.post(url: "/user/bind/request/", body: body).send();
    var responseBody = jsonDecode(response.body);
    debugPrint(response.statusCode.toString());
    debugPrint(response.body);
    if (!responseBody["success"]) {
      displayRequestBindingFailure(context, responseBody);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEmailCodePage(
          email: _controller.text,
          callback: (code) async {
            completeBinding(code);
          },
        ),
      ),
    );
  }

  void displayRequestBindingFailure(context, responseBody) {
    var description = "";
    if (responseBody["error"] == 1000) {
      description = Locales.string(
          context, "product.profile.email.connect.failure.email.format");
    } else if (responseBody["error"] == 1001) {
      description = Locales.string(
          context, "product.profile.email.connect.failure.email.existing");
    } else if (responseBody["error"] == 1002) {
      description = Locales.string(
          context, "product.profile.email.connect.failure.already.bound");
    }
    Alert(
      context: context,
      type: AlertType.error,
      title: Locales.string(
          context, "product.profile.email.connect.failure.title"),
      desc: description,
      buttons: [
        DialogButton(
          child:
              Text("OK", style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();
  }

  void completeBinding(code) async {
    var body = <String, Object>{"code": code};
    var response =
        await Request.post(url: "/user/bind/complete/", body: body).send();
    var responseBody = jsonDecode(response.body);
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
