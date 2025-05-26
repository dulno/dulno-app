import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CampaignTime extends StatelessWidget {
  final dynamic campaign;
  final bool? reduced;

  const CampaignTime({super.key, required this.campaign, this.reduced});

  @override
  Widget build(BuildContext context) {
    var start = formatDate(context, campaign["start"]);
    var end = formatDate(context, campaign["end"]);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: (reduced ?? false) ? 1 : 2,
        horizontal: (reduced ?? false) ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.clock,
              size: (reduced ?? false) ? 12 : 14, color: Colors.grey[600]),
          SizedBox(width: 5),
          Text(
            (start == end || (reduced ?? false)) ? start : "$start - $end",
            style: TextStyle(
              fontSize: (reduced ?? false) ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(context, time) {
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat.yMMMd(tag).format(dateTime);
  }
}
