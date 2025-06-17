import 'package:dulno/localization/locale_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CampaignBadge extends StatelessWidget {
  final String type;

  const CampaignBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: findCampaignBackgroundColor(),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          LocaleText(
            findCampaignName(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: findCampaignForegroundColor()),
          ),
          SizedBox(width: 12),
          FaIcon(findCampaignIcon(),
              size: 18, color: findCampaignForegroundColor()),
        ],
      ),
    );
  }

  String findCampaignName() {
    if (type == "DISCOUNT") {
      return "product.campaign.type.discount";
    } else if (type == "EVENT") {
      return "product.campaign.type.event";
    } else if (type == "LAUNCH") {
      return "product.campaign.type.launch";
    } else if (type == "SEASONAL") {
      return "product.campaign.type.seasonal";
    } else if (type == "RECRUITING") {
      return "product.campaign.type.recruiting";
    }
    return "product.campaign.type.default";
  }

  IconData findCampaignIcon() {
    if (type == "DISCOUNT") {
      return FontAwesomeIcons.percent;
    } else if (type == "EVENT") {
      return FontAwesomeIcons.solidCalendarDays;
    } else if (type == "LAUNCH") {
      return FontAwesomeIcons.rocket;
    } else if (type == "SEASONAL") {
      return FontAwesomeIcons.temperatureHalf;
    } else if (type == "RECRUITING") {
      return FontAwesomeIcons.userTie;
    }
    return FontAwesomeIcons.bullhorn;
  }

  Color? findCampaignBackgroundColor() {
    if (type == "DISCOUNT") {
      return Colors.redAccent;
    } else if (type == "EVENT") {
      return Colors.blueAccent;
    } else if (type == "LAUNCH") {
      return Colors.greenAccent;
    } else if (type == "SEASONAL") {
      return Colors.orangeAccent;
    } else if (type == "RECRUITING") {
      return Colors.deepPurpleAccent;
    }
    return Colors.grey[100];
  }

  Color? findCampaignForegroundColor() {
    if (type == "DISCOUNT") {
      return Colors.black;
    } else if (type == "EVENT") {
      return Colors.white;
    } else if (type == "LAUNCH") {
      return Colors.black;
    } else if (type == "SEASONAL") {
      return Colors.black;
    } else if (type == "RECRUITING") {
      return Colors.white;
    }
    return Colors.black;
  }
}
