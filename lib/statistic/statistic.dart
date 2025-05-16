import 'dart:convert';

import 'package:dulno/config/statistic_options.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DulnoStatistic {
  DulnoStatistic();

  Future<void> keep() async {
    sendAppOpen();
    sendUserJoin();
  }

  Future<void> sendAppOpen() async {
    var body = createStatisticBody();
    var info = await PackageInfo.fromPlatform();
    body["version"] = info.version;
    await Request.post(url: "/user/app/open/", body: body).send();
  }

  Future<void> sendUserJoin() async {
    const storage = FlutterSecureStorage();
    if (await storage.read(key: "alreadyOpened") != null) {
      return;
    }
    var body = createStatisticBody();
    var response = await Request.post(url: "/user/join/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return;
    }
    await storage.write(key: "alreadyOpened", value: "true");
  }

  Map<String, Object> createStatisticBody() {
    return <String, Object>{"key": StatisticOptions.statisticKey};
  }
}