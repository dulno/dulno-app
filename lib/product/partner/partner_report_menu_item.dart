import 'package:dulno/dropdown/dropdown_item.dart';
import 'package:dulno/product/partner/partner_report_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PartnerReportMenuItem extends DropdownItem {
  final BuildContext context;
  final String partner;

  PartnerReportMenuItem(
      {super.key, required this.context, required this.partner})
      : super(
          text: "product.partner.report",
          icon: const Icon(CupertinoIcons.flag),
          color: Colors.redAccent,
          click: () {
            PartnerReportPopup(partner: partner).show(context);
          },
        );
}
