import 'dart:convert';
import 'dart:io' show Directory, File;
import 'dart:typed_data';

import 'package:dulno/request/request.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardLogo {
  final String? cardId;
  final String? currentLogoId;
  Widget? logo;

  CardLogo({
    required this.cardId,
    required this.currentLogoId,
  });

  Future<Widget?> fetch(BuildContext context) async {
    if (!_hasValidIds) {
      return null;
    }
    if (logo != null) {
      return logo;
    }
    if (kIsWeb) {
      logo = await _fetchWeb(context);
    } else {
      logo = await _fetchMobile(context);
    }
    return logo;
  }

  bool get _hasValidIds => cardId != null && currentLogoId != null;

  Future<Widget> _fetchMobile(BuildContext context) async {
    final folder = await _ensureLocalFolder();
    final localFile = _localFileFor(currentLogoId!, folder);
    if (await localFile.exists()) {
      return Image.memory(await localFile.readAsBytes(), fit: BoxFit.contain);
    }
    final bytes = await _downloadLogoBytes(context);
    if (bytes == null) {
      return const SizedBox.shrink();
    }
    await _clearOldCache(folder);
    await localFile.writeAsBytes(bytes);
    return Image.memory(bytes, fit: BoxFit.contain);
  }

  Future<Widget> _fetchWeb(BuildContext context) async {
    final cached = await _getCachedWebLogoBytes();
    if (cached != null) {
      return Image.memory(cached, fit: BoxFit.contain);
    }
    final bytes = await _downloadLogoBytes(context);
    if (bytes == null) {
      return const SizedBox.shrink();
    }
    await _saveWebCache(bytes);
    return Image.memory(bytes, fit: BoxFit.contain);
  }

  Future<Uint8List?> _downloadLogoBytes(BuildContext context) async {
    final body = <String, Object>{"card": cardId!};
    final response =
        await Request.post(url: "/user/card/logo/", body: body).send(context);
    if (response == null || response.statusCode == 409) {
      return null;
    }
    final data = jsonDecode(response.body);
    final base64Logo = data["logo"] as String?;
    return base64Logo != null ? base64Decode(base64Logo) : null;
  }

  Future<Directory> _ensureLocalFolder() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(path.join(dir.path, 'dulno', 'card'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder;
  }

  File _localFileFor(String logoId, Directory folder) {
    return File(path.join(folder.path, "${cardId!}-$logoId"));
  }

  Future<void> _clearOldCache(Directory folder) async {
    final files = folder.listSync();
    for (var file in files) {
      if (file is File && file.path.contains(cardId!)) {
        await file.delete();
      }
    }
  }

  String get _webCacheKey => 'card-${cardId!}-$currentLogoId';

  Future<Uint8List?> _getCachedWebLogoBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final base64str = prefs.getString(_webCacheKey);
    if (base64str == null) return null;
    return base64Decode(base64str);
  }

  Future<void> _saveWebCache(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = base64Encode(bytes);
    final toRemove = prefs
        .getKeys()
        .where((k) => k.startsWith('card-${cardId!}-') && k != _webCacheKey)
        .toList();
    for (var k in toRemove) {
      await prefs.remove(k);
    }
    await prefs.setString(_webCacheKey, encoded);
  }
}
