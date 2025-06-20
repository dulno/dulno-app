import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ScanCooldown {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final int _duration = 1000 * 2;

  void enable() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    var cooldown = currentTime + _duration;
    await _storage.write(key: "scanCooldown", value: cooldown.toString());
  }

  Future<bool> isActive() async {
    final cooldownString = await _storage.read(key: "scanCooldown");
    if (cooldownString == null) {
      return false;
    }
    final cooldown = int.tryParse(cooldownString);
    if (cooldown == null) {
      return false;
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime < cooldown;
  }

  void reset() async {
    await _storage.delete(key: "scanCooldown");
  }
}
