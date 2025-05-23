import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/request/request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StampRedemption {
  final String stamp;
  final String picc;
  final String cmac;
  late Map<String, dynamic> responseBody;

  StampRedemption(
      {required this.stamp, required this.picc, required this.cmac});

  Future<int> redeem(context) async {
    const storage = FlutterSecureStorage();
    var body = <String, Object>{"stamp": stamp, "picc": picc, "cmac": cmac};
    final cardCache = await storage.read(key: "cards");
    var cards = (cardCache == null ? [] : jsonDecode(cardCache))
        .map((card) => card["itemId"])
        .toList();
    body["cards"] = cards;
    body["language"] = await storage.read(key: "language") ?? "de";
    final partnerCache = await storage.read(key: "partners");
    var partners = partnerCache == null ? [] : jsonDecode(partnerCache);
    body["partners"] = partners;
    var response =
        await Request.post(url: "/user/stamp/", body: body).send(context);
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

  Future<bool> redeemProcessed(context) async {
    var redemptionResult = await redeem(context);
    if (redemptionResult == 0) {
      processRedemptionUnconnected(context);
      return false;
    }
    if (redemptionResult == 1) {
      Navigator.pop(context);
      displayScanError(context, responseBody["error"]);
      return false;
    }
    return true;
  }

  Future<void> processRedemptionUnconnected(context) async {
    var scan = <String, Object>{"stamp": stamp, "picc": picc, "cmac": cmac};
    const storage = FlutterSecureStorage();
    final scanCache = await storage.read(key: "scans");
    var scans = scanCache == null ? [] : jsonDecode(scanCache);
    scans.add(scan);
    await storage.write(key: "scans", value: jsonEncode(scans));
    Navigator.pop(context);
    Alert(
      description: "product.scan.connection.cache",
      icon: CupertinoIcons.antenna_radiowaves_left_right,
    ).show(context);
  }

  void displayScanError(context, error) {
    var description = "";
    if (error == 1000) {
      description = "product.scan.error.stamp.existence";
    } else if (error == 1001) {
      description = "product.scan.error.stamp.state";
    } else if (error == 1002 || error == 1003) {
      description = "product.scan.error.scan.validation";
    } else if (error == 1004) {
      description = "product.scan.error.already.scanned";
    } else if (error == 1005) {
      description = "product.scan.error.card.existence";
    } else if (error == 1006) {
      description = "product.scan.error.value.absent";
    } else if (error == 1007) {
      description = "product.scan.error.member.absent";
    } else if (error == 1008) {
      description = "product.scan.error.already.member";
    }
    Alert(
      description: description,
      icon: CupertinoIcons.exclamationmark_triangle,
    ).show(context);
    return;
  }
}
