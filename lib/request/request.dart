import 'dart:convert';

import 'package:dulno/config/environment_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Request {
  var url;
  var method;
  var headers;
  var body;

  Request.get({required url, Map<String, String> this.headers = const {}}) {
    this.url = "https://${EnvironmentOptions.environment.endpoint}/v1$url";
    method = "GET";
  }

  Request.post({
    required url, Map<String, String> this.headers = const {},
    Map<String, String> this.body = const {},
  }) {
    this.url = "https://${EnvironmentOptions.environment.endpoint}/v1$url";
    method = "POST";
  }

  send() async {
    Map<String, String> headers = Map.from(this.headers);
    headers["Content-Type"] = "application/json; charset=UTF-8";
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: "token") ?? "";
    if (token != "") {
      headers["Authorization"] = "Bearer $token";
    }
    var response = await generateResponse(headers);
    return response;
  }

  generateResponse(headers) async {
    if (method == "GET") {
      return await http.get(Uri.parse(url), headers: headers);
    } else if (method == "POST") {
      Map<String, String> body = Map.from(this.body);
      return await http.post(Uri.parse(url), headers: headers,
        body: jsonEncode(body));
    }
  }
}