import 'dart:convert';

import 'package:dulno/product/card/card_element.dart';
import 'package:flutter/material.dart';

class CardPage extends StatelessWidget {
  final Map<String, dynamic> content;

  const CardPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in_map),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black12,
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: ProductCardElement(
                isLoading: false,
                content: content,
              ),
            ),
            new Divider(
              color: Colors.grey[300],
              height: 2,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              utf8.decode(content["partnerName"].toString().codeUnits),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              utf8.decode(findDescription().toString().codeUnits),
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  String findDescription() {
    var type = content["cardType"];
    if (type == "COLLECTION") {
      return content["rewardDescription"];
    } else if (type == "VALUE") {
      return content["valueDescription"];
    } else if (type == "MEMBER") {
      return content["memberDescription"];
    }
    return "";
  }
}
