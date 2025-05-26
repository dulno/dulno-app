import 'dart:convert';

import 'package:dulno/product/campaign/campaign_time.dart';
import 'package:dulno/product/partner/partner_logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CampaignElement extends StatefulWidget {
  final bool isLoading;
  final Map<String, dynamic> content;

  const CampaignElement(
      {super.key, required this.isLoading, required this.content});

  @override
  State<CampaignElement> createState() => _CampaignElementState();
}

class _CampaignElementState extends State<CampaignElement> {
  PartnerLogo? _logo;

  @override
  Widget build(BuildContext context) {
    return createCampaignElement();
  }

  Widget createCampaignElement() {
    if (!widget.isLoading) {
      _logo ??= PartnerLogo(
          partnerId: widget.content["partner"]["id"],
          currentLogoId: widget.content["partner"]["logoId"]);
    }
    const storage = FlutterSecureStorage();
    return FutureBuilder<dynamic>(
      future: _logo?.fetch(context),
      builder: (context, AsyncSnapshot<dynamic> logoSnapshot) {
        return FutureBuilder<String?>(
          future: storage.read(key: "viewedCampaigns"),
          builder: (context, AsyncSnapshot<String?> viewedCampaignsSnapshot) {
            var viewedCampaigns = viewedCampaignsSnapshot.connectionState ==
                    ConnectionState.waiting
                ? null
                : viewedCampaignsSnapshot.data == null
                    ? []
                    : jsonDecode(viewedCampaignsSnapshot.data!);
            return Skeletonizer(
              enabled: widget.isLoading,
              child: Container(
                width: 360,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: (_logo?.logo == null || widget.isLoading)
                                    ? Skeleton.leaf(
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 45,
                                        height: 45,
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                              color: Colors.black12, width: 1),
                                        ),
                                        child: ClipOval(child: _logo?.logo!),
                                      ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.isLoading
                                        ? "Lorem ipsum"
                                        : utf8.decode(widget.content["partner"]
                                                ["name"]
                                            .toString()
                                            .codeUnits),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  widget.isLoading
                                      ? Skeleton.leaf(
                                          child: Container(
                                            width: 150,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                        )
                                      : CampaignTime(
                                          campaign: widget.content,
                                          reduced: true),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.isLoading
                                  ? "Lorem ipsum"
                                  : utf8.decode(widget.content["title"]
                                      .toString()
                                      .codeUnits),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.isLoading
                                  ? "Lorem ipsum dolor sit amet, consetetur"
                                  : utf8.decode(widget.content["description"]
                                      .toString()
                                      .codeUnits),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          CupertinoIcons.right_chevron,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                    widget.isLoading ||
                            viewedCampaigns == null ||
                            viewedCampaigns.contains(widget.content["id"])
                        ? SizedBox.shrink()
                        : Positioned(
                            right: 2,
                            top: 5,
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
