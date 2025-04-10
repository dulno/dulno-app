import 'dart:convert';

import 'package:dulno/product/card/card_element.dart';
import 'package:dulno/product/partner/discover_map.dart';
import 'package:dulno/product/partner/partner_link_list.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CardPage extends StatelessWidget {
  final Map<String, dynamic> content;
  final MapController mapController = MapController();

  CardPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: findPartner(),
      builder: (context, AsyncSnapshot<dynamic> partner) {
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
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Container(
                color: Colors.black12,
                height: 1.0,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: createCardPageContent(partner),
            ),
          ),
        );
      },
    );
  }

  Widget createCardPageContent(AsyncSnapshot<dynamic> partner) {
    return Skeletonizer(
      enabled: !partner.hasData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ProductCardElement(
              isLoading: !partner.hasData,
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
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            utf8.decode(content["partnerDescription"].toString().codeUnits),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          SizedBox(
            height: 20,
          ),
          LocaleText(
            "product.card.about",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            utf8.decode(findDescription().toString().codeUnits),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          SizedBox(
            height: 20,
          ),
          LocaleText(
            "product.card.links",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          PartnerLinkList(partner: partner.data),
          SizedBox(
            height: 20,
          ),
          LocaleText(
            "product.card.locations",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          createMapElement(partner.data),
          SizedBox(
            height: 50,
          ),
        ],
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

  Widget createMapElement(partner) {
    if (partner == null) {
      return Skeleton.leaf(
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    var firstLocation = partner["locations"][0];
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: OSMMap(
          partners: [partner],
          mapController: mapController,
          latitude: firstLocation["latitude"],
          longitude: firstLocation["longitude"],
          radius: 1,
          initialZoom: 16,
        ),
      ),
    );
  }

  Future<dynamic> findPartner() async {
    var body = <String, Object>{"partner": content["partnerId"]};
    var response = await Request.post(url: "/user/partner/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return null;
    }
    return jsonDecode(response.body);
  }
}
