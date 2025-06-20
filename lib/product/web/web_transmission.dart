import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/alert/connection_alert.dart';
import 'package:dulno/alert/loader_alert.dart';
import 'package:dulno/product/base/page.dart';
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
      ConnectionAlert().show(context);
      return null;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return null;
    }
    var transmission = responseBody["transmission"];
    return "dulno-$transmission";
  }

  Future<bool> complete(BuildContext context, String transmission) async {
    if (!transmission.startsWith("dulno-")) {
      return false;
    }
    transmission = transmission.replaceFirst("dulno-", "");
    const storage = FlutterSecureStorage();
    var body = <String, Object>{"transmission": transmission};
    final cardCache = await storage.read(key: "cards");
    var cards = (cardCache == null ? [] : jsonDecode(cardCache))
        .map((card) => card["itemId"])
        .toList();
    body["cards"] = cards;
    LoaderAlert().show(context);
    var response =
        await Request.post(url: "/user/transmission/complete/", body: body)
            .send(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null || response.statusCode == 409) {
      ConnectionAlert().show(context);
      return false;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      Alert(
        description: "product.transmission.failed",
        type: AlertType.error,
      ).show(context);
      return false;
    }
    var items = responseBody["items"];
    await storage.write(key: "cards", value: jsonEncode(items));
    return true;
  }

  Future<void> processedCompletion(BuildContext context,
      GlobalKey<ProductPageState> productPageKey, String transmission) async {
    productPageKey.currentState!.findCardListBody().prohibitLoadRefresh();
    bool success = await WebTransmission().complete(context, transmission);
    if (!success) {
      return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProductPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    Alert(
      description: "product.transmission.success",
      type: AlertType.success,
    ).show(context);
  }
}
