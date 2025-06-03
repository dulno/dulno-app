import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';

class ScanHistoryEntry {
  static ScanHistoryEntry of(Map<String, dynamic> data) {
    return ScanHistoryEntry(
      entryType: data["entryType"],
      cardType: data["cardType"],
      partnerName: data["partnerName"],
      timestamp: data["timestamp"],
    );
  }

  final String entryType;
  final String cardType;
  final String partnerName;
  final int timestamp;

  ScanHistoryEntry({
    required this.entryType,
    required this.cardType,
    required this.partnerName,
    required this.timestamp,
  });

  IconData icon() {
    if (entryType == "CREATE") {
      return CupertinoIcons.checkmark;
    } else if (entryType == "REMOVE") {
      return CupertinoIcons.xmark;
    } else if (entryType == "UPDATE" && cardType == "COLLECTION") {
      return CupertinoIcons.plus;
    } else if (entryType == "UPDATE" && cardType == "VALUE") {
      return CupertinoIcons.minus;
    }
    return CupertinoIcons.circle;
  }

  Color iconColor() {
    if (entryType == "CREATE") {
      return Colors.green;
    } else if (entryType == "REMOVE") {
      return Colors.red;
    }
    return Colors.black;
  }

  Color backgroundColor() {
    if (entryType == "CREATE") {
      return Colors.green[50]!;
    } else if (entryType == "REMOVE") {
      return Colors.red[50]!;
    }
    return Colors.white;
  }

  String title(context) {
    if (entryType == "CREATE") {
      return Locales.string(context, "product.scan.history.create.title");
    } else if (entryType == "REMOVE" && cardType == "VALUE") {
      return Locales.string(context, "product.scan.history.delete.value.title");
    } else if (entryType == "REMOVE" && cardType == "MEMBER") {
      return Locales.string(
          context, "product.scan.history.delete.member.title");
    } else if (entryType == "UPDATE" && cardType == "COLLECTION") {
      return Locales.string(
          context, "product.scan.history.update.collection.title");
    } else if (entryType == "UPDATE" && cardType == "VALUE") {
      return Locales.string(context, "product.scan.history.update.value.title");
    }
    return "";
  }

  String description(context) {
    if (entryType == "CREATE") {
      return Locales.string(context, "product.scan.history.create.description")
          .replaceAll("%s", partnerName);
    } else if (entryType == "REMOVE" && cardType == "VALUE") {
      return Locales.string(
          context, "product.scan.history.delete.value.description");
    } else if (entryType == "REMOVE" && cardType == "MEMBER") {
      return Locales.string(
          context, "product.scan.history.delete.member.description");
    } else if (entryType == "UPDATE" && cardType == "COLLECTION") {
      return Locales.string(
          context, "product.scan.history.update.collection.description");
    } else if (entryType == "UPDATE" && cardType == "VALUE") {
      return Locales.string(
          context, "product.scan.history.update.value.description");
    }
    return "";
  }

  String date(context) {
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.yMMMd(tag).add_jm().format(dateTime);
  }
}
