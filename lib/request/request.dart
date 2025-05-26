import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/config/environment_options.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/profile/profile_logout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

class Request {
  final String url;
  final String method;
  final Map<String, String> headers;
  final Map<String, Object> body;

  Request.get(
      {required String url, this.headers = const {}, this.body = const {}})
      : url = "https://${EnvironmentOptions.environment.endpoint}/v1$url",
        method = "GET";

  Request.post(
      {required String url, this.headers = const {}, this.body = const {}})
      : url = "https://${EnvironmentOptions.environment.endpoint}/v1$url",
        method = "POST";

  Future<Response?> send(context) async {
    Map<String, String> headers = Map.from(this.headers);
    headers["Content-Type"] = "application/json; charset=UTF-8";
    const storage = FlutterSecureStorage();
    String authenticationToken =
        await storage.read(key: "authenticationToken") ?? "";
    if (authenticationToken != "") {
      headers["Authorization"] = "Bearer $authenticationToken";
    }
    var response = await generateResponse(headers);
    if (response?.statusCode == 403) {
      await reset(context);
      return response;
    }
    if (response?.statusCode == 417) {
      var refreshResult = await refresh(context);
      if (refreshResult == true) {
        return await send(context);
      }
      await reset(context);
      return response;
    }
    return response;
  }

  Future<Response?> generateResponse(headers) async {
    if (method == "GET") {
      try {
        return await get(Uri.parse(url), headers: headers);
      } catch (exception) {
        return null;
      }
    } else if (method == "POST") {
      try {
        Map<String, Object> body = Map.from(this.body);
        return await post(Uri.parse(url),
            headers: headers, body: jsonEncode(body));
      } catch (exception) {
        return null;
      }
    } else {
      throw UnsupportedError("Unsupported HTTP method: $method");
    }
  }

  refresh(context) async {
    const storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: "refreshToken") ?? "";
    if (refreshToken == "") {
      return false;
    }
    var response = await Request.post(
        url: "/user/authorization/refresh/",
        body: <String, String>{"refreshToken": refreshToken}).send(context);
    if (response == null || response.statusCode == 409) {
      return false;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] == false) {
      return false;
    }
    await storage.write(
        key: "authenticationToken", value: responseBody["authenticationToken"]);
    await storage.write(
        key: "refreshToken", value: responseBody["refreshToken"]);
    return true;
  }

  reset(context) async {
    await ProfileLogout().reset(context);
    Alert(
      description: "connection.logout",
      icon: CupertinoIcons.exclamationmark_triangle,
      callback: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    ).show(context);
  }
}
