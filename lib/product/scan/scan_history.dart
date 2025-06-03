import 'dart:convert';

import 'package:dulno/product/scan/scan_history_entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ScanHistory {
  Future<void> store(stampResponse) async {
    var entry = stampResponse;
    entry["entryType"] = stampResponse["action"];
    entry.remove("action");
    entry["timestamp"] = DateTime.now().millisecondsSinceEpoch;
    const storage = FlutterSecureStorage();
    final rawHistory = await storage.read(key: "history");
    var history = rawHistory == null ? [] : jsonDecode(rawHistory);
    history.add(entry);
    if (history.length > 100) {
      history.removeAt(0);
    }
    await storage.write(key: "history", value: jsonEncode(history));
  }

  Future<List<ScanHistoryEntry>> find() async {
    const storage = FlutterSecureStorage();
    final rawHistory = await storage.read(key: "history");
    debugPrint(rawHistory?.length.toString());
    var history = rawHistory == null ? [] : jsonDecode(rawHistory);
    var entries = <ScanHistoryEntry>[];
    for (var entry in history) {
      entries.add(ScanHistoryEntry.of(entry));
    }
    return entries;
  }
}
