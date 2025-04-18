import 'dart:convert';

import 'package:dulno/request/request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StampRedemption {
  final String stamp;
  final String picc;
  final String cmac;
  late Map<String, dynamic> responseBody;

  StampRedemption(
      {required this.stamp, required this.picc, required this.cmac});

  Future<int> redeem() async {
    const storage = FlutterSecureStorage();
    var body = <String, Object>{"stamp": stamp, "picc": picc, "cmac": cmac};
    if (await storage.read(key: "user") == null) {
      final cardCache = await storage.read(key: "cards");
      var cards = (cardCache == null ? [] : jsonDecode(cardCache))
          .map((card) => card["itemId"])
          .toList();
      body["cards"] = cards;
      body["language"] = await storage.read(key: "language") ?? "de";
      final partnerCache = await storage.read(key: "partners");
      var partners = partnerCache == null ? [] : jsonDecode(partnerCache);
      body["partners"] = partners;
    }
    var response = await Request.post(url: "/user/stamp/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return 0;
    }
    responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return 1;
    }
    await updateCardCache(responseBody);
    return 2;
  }

  Future<void> updateCardCache(responseBody) async {
    const storage = FlutterSecureStorage();
    final cardCache = await storage.read(key: "cards");
    var cards = cardCache == null ? [] : jsonDecode(cardCache);
    var action = responseBody["action"];
    responseBody.remove("success");
    responseBody.remove("action");
    if (action == "CREATE") {
      cards.add(responseBody);
      checkIsNewPartner(responseBody);
    } else {
      cards.removeWhere((card) => card["itemId"] == responseBody["itemId"]);
      if (action == "UPDATE") {
        cards.add(responseBody);
      }
    }
    await storage.write(key: "cards", value: jsonEncode(cards));
  }

  Future<void> checkIsNewPartner(responseBody) async {
    const storage = FlutterSecureStorage();
    final partnerCache = await storage.read(key: "partners");
    var partners = partnerCache == null ? [] : jsonDecode(partnerCache);
    var partnerId = responseBody["partnerId"];
    if (!partners.contains(partnerId)) {
      partners.add(partnerId);
      await storage.write(key: "partners", value: jsonEncode(partners));
    }
    FirebaseMessaging.instance.subscribeToTopic(partnerId);
  }
}
