import 'dart:convert';
import 'dart:math';

import 'package:dulno/config/environment_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hashlib/hashlib.dart';
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

  Future<Response?> send() async {
    Map<String, String> headers = Map.from(this.headers);
    headers["Content-Type"] = "application/json; charset=UTF-8";
    const storage = FlutterSecureStorage();
    String user = await storage.read(key: "user") ?? "";
    String authenticationKey =
        await storage.read(key: "authenticationKey") ?? "";
    if (user != "" && authenticationKey != "") {
      var time = DateTime.now().millisecondsSinceEpoch;
      var content = user + authenticationKey + time.toString();
      final hash = await compute(computeHash, {"content": content});
      headers["User"] = user;
      headers["Authentication"] = hash["hash"] ?? "";
      headers["Time"] = time.toString();
    }
    var response = await generateResponse(headers);
    return response;
  }

  Map<String, String> computeHash(Map<String, dynamic> args) {
    var random = Random.secure();
    var salt =
        String.fromCharCodes(List.generate(16, (_) => random.nextInt(94) + 33));
    var hash = argon2i(args['content'].codeUnits, salt.codeUnits,
            security: Argon2Security('dulno', m: 32768, p: 1, t: 2))
        .encoded();
    return {"hash": hash};
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
}
