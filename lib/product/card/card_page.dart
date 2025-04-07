import 'dart:convert';

import 'package:dulno/product/card/card_element.dart';
import 'package:dulno/product/partner/discover_map.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class CardPage extends StatelessWidget {
  final Map<String, dynamic> content;
  final MapController mapController = MapController();

  CardPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: findPartner(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> partner) {
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

  Widget createCardPageContent(AsyncSnapshot<Map<String, dynamic>> partner) {
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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
          createLinksElement(partner.data),
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

  Widget createLinksElement(partner) {
    if (partner == null) {
      return Column(
        children: [placeholderLink(), placeholderLink()],
      );
    }
    var elements = <Widget>[];
    for (var link in partner["links"]) {
      var type = link["type"];
      if (type != "WEBSITE" &&
          type != "INSTAGRAM" &&
          type != "FACEBOOK" &&
          type != "TIKTOK") {
        continue;
      }
      elements.add(
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: GestureDetector(
            onTap: () async {
              await launchUrl(Uri.parse(link["link"]));
            },
            child: Row(
              children: [
                createLinkIcon(type),
                SizedBox(
                  width: 10,
                ),
                LocaleText(
                  createLinkText(type),
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ),
      );
    }
    if (elements.isEmpty) {
      elements.add(LocaleText("product.card.links.empty"));
    }
    return Column(children: elements);
  }

  Widget placeholderLink() {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.globe, size: 20),
          SizedBox(
            width: 10,
          ),
          LocaleText(
            "product.card.link.website",
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget createLinkIcon(type) {
    if (type == "WEBSITE") {
      return FaIcon(FontAwesomeIcons.globe, size: 20);
    } else if (type == "INSTAGRAM") {
      return FaIcon(FontAwesomeIcons.instagram, size: 20);
    } else if (type == "FACEBOOK") {
      return FaIcon(FontAwesomeIcons.facebook, size: 20);
    } else if (type == "TIKTOK") {
      return FaIcon(FontAwesomeIcons.tiktok, size: 20);
    }
    return SizedBox.shrink();
  }

  String createLinkText(type) {
    if (type == "WEBSITE") {
      return "product.card.link.website";
    } else if (type == "INSTAGRAM") {
      return "product.card.link.instagram";
    } else if (type == "FACEBOOK") {
      return "product.card.link.facebook";
    } else if (type == "TIKTOK") {
      return "product.card.link.tiktok";
    }
    return "";
  }

  Widget createMapElement(partner) {
    if (partner == null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
    var locations = <LatLng>[];
    for (var location in partner["locations"]) {
      locations.add(LatLng(location["latitude"], location["longitude"]));
    }
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
          data: locations,
          mapController: mapController,
          latitude: locations[0].latitude,
          longitude: locations[0].longitude,
          radius: 1,
          initialZoom: 16,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> findPartner() async {
    var body = <String, Object>{"partner": content["partnerId"]};
    var response = await Request.post(url: "/user/partner/", body: body).send();
    return jsonDecode(response.body);
  }
}
