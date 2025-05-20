import 'dart:convert';

import 'package:dulno/product/partner/discover_map.dart';
import 'package:dulno/product/partner/partner_link_list.dart';
import 'package:dulno/product/partner/partner_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PartnerOverview extends StatefulWidget {
  final Map<String, dynamic> partner;

  const PartnerOverview({super.key, required this.partner});

  @override
  State<PartnerOverview> createState() => _PartnerOverviewState();
}

class _PartnerOverviewState extends State<PartnerOverview> {
  final MapController mapController = MapController();
  PartnerLogo? _logo;

  @override
  Widget build(BuildContext context) {
    _logo ??= PartnerLogo(
        partnerId: widget.partner["id"],
        currentLogoId: widget.partner["logoId"]);
    return FutureBuilder<dynamic>(
      future: _logo?.fetch(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Skeletonizer(
          enabled: _logo?.logo == null,
          child: Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _logo?.logo == null
                        ? Skeleton.leaf(
                            child: Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          )
                        : Container(
                            constraints: BoxConstraints(
                              maxWidth: 135,
                              maxHeight: 90,
                            ),
                            child: _logo?.logo!,
                          ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    utf8.decode(widget.partner["name"].toString().codeUnits),
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    utf8.decode(
                        widget.partner["description"].toString().codeUnits),
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  SizedBox(height: 30),
                  LocaleText(
                    "product.partner.popup.links",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  PartnerLinkList(partner: widget.partner),
                  SizedBox(height: 30),
                  createMapElement(widget.partner),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
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
          latitude: firstLocation["latitude"],
          longitude: firstLocation["longitude"],
          radius: 1,
          initialZoom: 16,
          locationDetails: false,
        ),
      ),
    );
  }
}
