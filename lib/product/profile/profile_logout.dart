import 'package:dulno/config/google_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileLogout {
  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "email");
    await storage.delete(key: "user");
    await storage.delete(key: "authenticationKey");
    await GoogleOptions.googleSignIn.signOut();
  }
}
