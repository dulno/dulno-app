import 'dart:convert';

import 'package:dulno/product/partner/partner_link_list.dart';
import 'package:dulno/product/partner/partner_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PartnerPopup extends StatefulWidget {
  final Map<String, dynamic> partner;
  final Map<String, dynamic> location;

  const PartnerPopup(
      {super.key, required this.partner, required this.location});

  @override
  State<PartnerPopup> createState() => _DraggablePopupState();
}

class _DraggablePopupState extends State<PartnerPopup> {
  double _popupHeight = 300.0;
  double _startDragHeight = 300.0;
  double _startVerticalDrag = 0.0;
  PartnerLogo? _logo;

  @override
  Widget build(BuildContext context) {
    _logo ??= PartnerLogo(partnerId: widget.partner["id"],
        currentLogoId: widget.partner["logoId"]);
    return FutureBuilder<dynamic>(
      future: _logo?.fetch(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onVerticalDragStart: (details) {
              _startVerticalDrag = details.localPosition.dy;
              _startDragHeight = _popupHeight;
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                _popupHeight = _startDragHeight +
                    (_startVerticalDrag - details.localPosition.dy);
                _popupHeight = _popupHeight.clamp(100.0, 600.0);
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 50),
              height: _popupHeight,
              decoration: BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Skeletonizer(
                enabled: _logo?.logo == null,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        width: 75,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _logo?.logo == null
                                  ? Skeleton.leaf(
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(25),
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
                              utf8.decode(
                                  widget.partner["name"].toString().codeUnits),
                              style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              utf8.decode(widget.partner["description"]
                                  .toString()
                                  .codeUnits),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            SizedBox(height: 30),
                            LocaleText(
                              "product.partner.popup.address",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              utf8.decode(widget.location["address"]
                                  .toString()
                                  .codeUnits),
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 20),
                            LocaleText(
                              "product.partner.popup.links",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            PartnerLinkList(partner: widget.partner),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
