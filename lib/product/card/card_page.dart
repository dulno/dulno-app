import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/alert/connection_alert.dart';
import 'package:dulno/alert/loader_alert.dart';
import 'package:dulno/dropdown/dropdown.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/card/card_element.dart';
import 'package:dulno/product/partner/discover_map.dart';
import 'package:dulno/product/partner/partner_link_list.dart';
import 'package:dulno/product/partner/partner_report_menu_item.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CardPage extends StatelessWidget {
  final Map<String, dynamic> content;
  final MapController mapController = MapController();

  CardPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: findPartner(context),
      builder: (context, AsyncSnapshot<dynamic> partner) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(CupertinoIcons.arrow_left),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[
              Dropdown(
                icon: Icon(CupertinoIcons.ellipsis),
                items: [
                  PartnerReportMenuItem(
                      context: context, partner: content["partnerId"])
                ],
              )
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
          backgroundColor: Color(0xFFFAFAFA),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: createCardPageContent(context, partner),
            ),
          ),
        );
      },
    );
  }

  Widget createCardPageContent(context, AsyncSnapshot<dynamic> partner) {
    return Skeletonizer(
      enabled: !partner.hasData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            child: CardElement(
              isLoading: !partner.hasData,
              content: content,
              animateLastStamp: false,
              animateCard: false,
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
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                  alignment: Alignment.center),
              onPressed: () async {
                Alert(
                  description: "product.card.delete.alert",
                  icon: CupertinoIcons.exclamationmark_triangle,
                  confirmButtonText: "product.card.delete.continue",
                  confirmButtonColor: Colors.redAccent,
                  cancelButton: true,
                  callback: () {
                    LoaderAlert().show(context);
                    deleteCard(context);
                  },
                ).show(context);
              },
              icon: Container(
                margin: EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LocaleText(
                    "product.card.delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: OSMMap(
          partners: [partner],
          mapController: mapController,
          latitude: firstLocation["latitude"] + 0.00075,
          longitude: firstLocation["longitude"],
          radius: 1,
          initialZoom: 16,
          locationDetails: false,
        ),
      ),
    );
  }

  void deleteCard(context) async {
    var body = <String, Object>{"item": content["itemId"]};
    var response =
        await Request.post(url: "/user/card/delete/", body: body).send(context);
    if (response == null || response.statusCode == 409) {
      ConnectionAlert().show(context);
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] == false) {
      Alert(description: "product.card.delete.failed", type: AlertType.error)
          .show(context);
      return;
    }
    deletionUpdateCardCache();
    Alert(
      description: "product.card.delete.successful",
      type: AlertType.success,
      callback: () {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductPage(),
          ),
          (route) => false,
        );
      },
    ).show(context);
  }

  Future<void> deletionUpdateCardCache() async {
    const storage = FlutterSecureStorage();
    final cardCache = await storage.read(key: "cards");
    var cards = cardCache == null ? [] : jsonDecode(cardCache);
    cards.removeWhere((card) => card["itemId"] == content["itemId"]);
    await storage.write(key: "cards", value: jsonEncode(cards));
  }

  Future<dynamic> findPartner(context) async {
    var body = <String, Object>{"partner": content["partnerId"]};
    var response =
        await Request.post(url: "/user/partner/", body: body).send(context);
    if (response == null || response.statusCode == 409) {
      return null;
    }
    return jsonDecode(response.body);
  }
}
