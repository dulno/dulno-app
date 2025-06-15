import 'dart:convert';

import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebTransmission {
  WebTransmission();

  Future<String?> request(BuildContext context) async {
    const storage = FlutterSecureStorage();
    var body = <String, Object>{};
    final cardCache = await storage.read(key: "cards");
    var cards = (cardCache == null ? [] : jsonDecode(cardCache))
        .map((card) => card["itemId"])
        .toList();
    body["cards"] = cards;
    var response =
        await Request.post(url: "/user/transmission/request/", body: body)
            .send(context);
    if (response == null || response.statusCode == 409) {
      return null;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return null;
    }
    var transmission = responseBody["transmission"];
    return "dulno-$transmission";
  }

  Future<void> complete(BuildContext context, String transmission) async {
    transmission = transmission.replaceFirst("dulno-", "");
    const storage = FlutterSecureStorage();
    var body = <String, Object>{"transmission": transmission};
    final cardCache = await storage.read(key: "cards");
    var cards = (cardCache == null ? [] : jsonDecode(cardCache))
        .map((card) => card["itemId"])
        .toList();
    body["cards"] = cards;
    var response =
        await Request.post(url: "/user/transmission/complete/", body: body)
            .send(context);
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return;
    }
    var items = responseBody["items"];
    await storage.write(key: "cards", value: jsonEncode(items));
  }
}
