import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnerLinkList extends StatelessWidget {
  const PartnerLinkList({super.key, required this.partner});

  final Map<String, dynamic>? partner;

  @override
  Widget build(BuildContext context) {
    if (partner == null) {
      return Column(
        children: [placeholderLink(), placeholderLink()],
      );
    }
    var elements = <Widget>[];
    for (var link in partner!["links"]) {
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
      elements.add(LocaleText("product.partner.links.empty"));
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
            "product.partner.link.website",
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
      return "product.partner.link.website";
    } else if (type == "INSTAGRAM") {
      return "product.partner.link.instagram";
    } else if (type == "FACEBOOK") {
      return "product.partner.link.facebook";
    } else if (type == "TIKTOK") {
      return "product.partner.link.tiktok";
    }
    return "";
  }
}
