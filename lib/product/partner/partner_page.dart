import 'package:dulno/product/partner/partner_overview.dart';
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
      body: PartnerOverview(partner: partner),
    );
  }
}
