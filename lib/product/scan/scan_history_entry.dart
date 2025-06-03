import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScanHistoryEntry {
  static ScanHistoryEntry of(Map<String, dynamic> data) {
    return ScanHistoryEntry(
      entryType: data["entryType"],
      cardType: data["cardType"],
      partnerName: data["partnerName"],
      timestamp: data["timestamp"],
      data: data,
    );
  }

  final String entryType;
  final String cardType;
  final String partnerName;
  final int timestamp;
  final Map<String, dynamic> data;

  ScanHistoryEntry({
    required this.entryType,
    required this.cardType,
    required this.partnerName,
    required this.timestamp,
    required this.data,
  });

  IconData icon() {
    if (entryType == "CREATE") {
      return CupertinoIcons.checkmark;
    } else if (entryType == "REMOVE") {
      return CupertinoIcons.xmark;
    } else if (entryType == "UPDATE" &&
        cardType == "COLLECTION" &&
        data["stamps"] == 0) {
      return CupertinoIcons.gift;
    } else if (entryType == "UPDATE" && cardType == "COLLECTION") {
      return CupertinoIcons.plus;
    } else if (entryType == "UPDATE" && cardType == "VALUE") {
      return CupertinoIcons.minus;
    }
    return CupertinoIcons.circle;
  }

  Color iconColor() {
    if (entryType == "CREATE" ||
        (entryType == "UPDATE" &&
            cardType == "COLLECTION" &&
            data["stamps"] == 0)) {
      return Colors.green;
    } else if (entryType == "REMOVE") {
      return Colors.red;
    }
    return Colors.black;
  }

  Color backgroundColor() {
    if (entryType == "CREATE" ||
        (entryType == "UPDATE" &&
            cardType == "COLLECTION" &&
            data["stamps"] == 0)) {
      return Colors.green[50]!;
    } else if (entryType == "REMOVE") {
      return Colors.red[50]!;
    }
    return Colors.white;
  }

  String title() {
    if (entryType == "CREATE") {
      return "product.scan.history.create.title";
    } else if (entryType == "REMOVE" && cardType == "VALUE") {
      return "product.scan.history.delete.value.title";
    } else if (entryType == "REMOVE" && cardType == "MEMBER") {
      return "product.scan.history.delete.member.title";
    } else if (entryType == "UPDATE" &&
        cardType == "COLLECTION" &&
        data["stamps"] == 0) {
      return "product.scan.history.update.collection.full.title";
    } else if (entryType == "UPDATE" && cardType == "COLLECTION") {
      return "product.scan.history.update.collection.title";
    } else if (entryType == "UPDATE" && cardType == "VALUE") {
      return "product.scan.history.update.value.title";
    }
    return "";
  }

  String description() {
    if (entryType == "CREATE") {
      return "product.scan.history.create.description";
    } else if (entryType == "REMOVE" && cardType == "VALUE") {
      return "product.scan.history.delete.value.description";
    } else if (entryType == "REMOVE" && cardType == "MEMBER") {
      return "product.scan.history.delete.member.description";
    } else if (entryType == "UPDATE" &&
        cardType == "COLLECTION" &&
        data["stamps"] == 0) {
      return "product.scan.history.update.collection.full.description";
    } else if (entryType == "UPDATE" && cardType == "COLLECTION") {
      return "product.scan.history.update.collection.description";
    } else if (entryType == "UPDATE" && cardType == "VALUE") {
      return "product.scan.history.update.value.description";
    }
    return "";
  }

  String date(context) {
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.yMMMd(tag).add_jm().format(dateTime);
  }
}
