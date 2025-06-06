import 'package:dulno/dropdown/dropdown.dart';
import 'package:dulno/product/partner/partner_overview.dart';
import 'package:dulno/product/partner/partner_report_menu_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PartnerPage extends StatelessWidget {
  final Map<String, dynamic> partner;

  const PartnerPage({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
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
              PartnerReportMenuItem(context: context, partner: partner["id"])
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
      body: PartnerOverview(partner: partner),
    );
  }
}
