import 'package:dulno/product/partner/partner_logo.dart';
import 'package:flutter/material.dart';
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
    return FutureBuilder<dynamic>(
      future: _logo?.fetch(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Skeletonizer(
          enabled: widget.isLoading,
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(12),
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
                                height: 75,
                                width: 75,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.black12, width: 1),
                                ),
                              ),
                              child: _logo?.logo!,
                            ),
                    ),
                    widget.isLoading
                        ? Container(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.only(top: 100),
                            child: Skeleton.leaf(
                              child: Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          )
                        : createCampaignContent(),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      widget.isLoading
                          ? "Test"
                          : widget.content["partner"]["name"],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget createCampaignContent() {
    return Container();
  }
}
