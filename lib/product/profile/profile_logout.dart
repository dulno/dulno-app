import 'package:dulno/config/google_options.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileLogout {
  Future<void> logout(context) async {
    await Request.get(url: "/user/logout/").send(context);
    await reset(context);
  }

  Future<void> reset(context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "email");
    await storage.delete(key: "user");
    await storage.delete(key: "authenticationToken");
    await storage.delete(key: "refreshToken");
    await GoogleOptions.googleSignIn.signOut();
  }
}
