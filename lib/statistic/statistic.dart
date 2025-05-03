import 'package:dulno/request/request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DulnoStatistic {
  DulnoStatistic();

  Future<void> keep() async {
    await Request.get(url: "/user/app/open/").send();
    const storage = FlutterSecureStorage();
    if (await storage.read(key: "alreadyOpened") != null) {
      return;
    }
    await storage.write(key: "alreadyOpened", value: "true");
    await Request.get(url: "/user/join/").send();
  }
}