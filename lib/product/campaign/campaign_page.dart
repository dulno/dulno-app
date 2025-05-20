import 'dart:convert';

import 'package:dulno/product/campaign/campaign_batch.dart';
import 'package:dulno/product/campaign/campaign_time.dart';
import 'package:dulno/product/partner/partner_logo.dart';
import 'package:dulno/product/partner/partner_page.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CampaignPage extends StatelessWidget {
  final String partner;
  final String campaign;
  final Function()? callback;
  PartnerLogo? _logo;

  CampaignPage({
    super.key,
    required this.partner,
    required this.campaign,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    storeViewedCampaign();
    return FutureBuilder<dynamic>(
      future: findCampaign(),
      builder: (context, AsyncSnapshot<dynamic> campaignSnapshot) {
        _logo ??= PartnerLogo(partnerId: partner, currentLogoId: campaign);
        return FutureBuilder<dynamic>(
          future: _logo?.fetch(),
          builder: (context, AsyncSnapshot<dynamic> logoSnapshot) {
            var loading = !campaignSnapshot.hasData || _logo?.logo == null;
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
              body: Container(
                padding: EdgeInsets.all(20),
                child: Skeletonizer(
                  enabled: loading,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            !loading
                                ? CampaignBadge(
                                    type: campaignSnapshot.data["type"])
                                : Skeleton.leaf(
                                    child: Container(
                                      height: 30,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                            loading
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
                          ],
                        ),
                        SizedBox(height: 60),
                        Text(
                          !loading
                              ? utf8.decode(campaignSnapshot.data["title"]
                                  .toString()
                                  .codeUnits)
                              : "Lorem ipsum",
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        loading
                            ? Skeleton.leaf(
                                child: Container(
                                  height: 20,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              )
                            : CampaignTime(campaign: campaignSnapshot.data),
                        SizedBox(height: 15),
                        Text(
                          !loading
                              ? utf8.decode(campaignSnapshot.data["description"]
                                  .toString()
                                  .codeUnits)
                              : "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 80),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PartnerPage(
                                    partner: campaignSnapshot.data["partner"],
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.indigo),
                              shape: WidgetStateProperty.all(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)))),
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15)),
                              minimumSize: WidgetStateProperty.all(Size(0, 0)),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: LocaleText("product.campaign.redirect",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<dynamic> findCampaign() async {
    var body = <String, Object>{"campaign": campaign};
    var response =
        await Request.post(url: "/user/campaign/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<void> storeViewedCampaign() async {
    const storage = FlutterSecureStorage();
    final viewedCampaignsCache = await storage.read(key: "viewedCampaigns");
    var viewedCampaigns =
        viewedCampaignsCache == null ? [] : jsonDecode(viewedCampaignsCache);
    viewedCampaigns.add(campaign);
    await storage.write(
        key: "viewedCampaigns", value: jsonEncode(viewedCampaigns));
    callback?.call();
  }
}
