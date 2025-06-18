import 'dart:convert';

import 'package:dulno/dropdown/dropdown.dart';
import 'package:dulno/localization/locale_text.dart';
import 'package:dulno/localization/locales.dart';
import 'package:dulno/product/campaign/campaign_badge.dart';
import 'package:dulno/product/campaign/campaign_time.dart';
import 'package:dulno/product/coupon/coupon_element.dart';
import 'package:dulno/product/partner/partner_logo.dart';
import 'package:dulno/product/partner/partner_page.dart';
import 'package:dulno/product/partner/partner_report_menu_item.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CampaignPage extends StatefulWidget {
  final String partner;
  final String campaign;
  final Function()? callback;

  const CampaignPage({
    super.key,
    required this.partner,
    required this.campaign,
    this.callback,
  });

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  late PartnerLogo _logo;
  late Future _logoFetch;
  late Future _campaignFetch;

  @override
  void initState() {
    super.initState();
    _logo =
        PartnerLogo(partnerId: widget.partner, currentLogoId: widget.campaign);
    _logoFetch = _logo.fetch(context);
    _campaignFetch = findCampaign(context);
  }

  @override
  Widget build(BuildContext context) {
    storeViewedCampaign();
    const storage = FlutterSecureStorage();
    return FutureBuilder<dynamic>(
      future: _campaignFetch,
      builder: (context, AsyncSnapshot<dynamic> campaignSnapshot) {
        return FutureBuilder<dynamic>(
          future: storage.read(key: "collectedCoupons"),
          builder: (context, AsyncSnapshot<dynamic> collectedCouponsSnapshot) {
            return FutureBuilder<dynamic>(
              future: _logoFetch,
              builder: (context, AsyncSnapshot<dynamic> logoSnapshot) {
                var loading = !campaignSnapshot.hasData || _logo.logo == null;
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
                          PartnerReportMenuItem(
                              context: context, partner: widget.partner)
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
                  body: Skeletonizer(
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
                              loading
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
                                      height: 90,
                                      constraints: BoxConstraints(
                                        maxWidth: 135,
                                      ),
                                      child: _logo.logo!,
                                    ),
                              !loading
                                  ? CampaignBadge(
                                      type: campaignSnapshot.data["type"])
                                  : Skeleton.leaf(
                                      child: Container(
                                        height: 30,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Divider(
                              color: Colors.grey[300],
                              height: 2,
                            ),
                          ),
                          !loading && campaignSnapshot.data["coupon"]["found"]
                              ? CouponElement(
                                  isLoading: false,
                                  content: campaignSnapshot.data["coupon"],
                                  state: CouponElementState.collectable,
                                  unusable: !isCouponUsable(
                                      loading,
                                      campaignSnapshot,
                                      collectedCouponsSnapshot),
                                )
                              : SizedBox(),
                          createLimitationElement(context, loading,
                              campaignSnapshot, collectedCouponsSnapshot),
                          !loading && campaignSnapshot.data["coupon"]["found"]
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(
                                    color: Colors.grey[300],
                                    height: 2,
                                  ),
                                )
                              : SizedBox(),
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
                                ? utf8.decode(campaignSnapshot
                                    .data["description"]
                                    .toString()
                                    .codeUnits)
                                : "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 80),
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.indigo),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 8)),
                                  alignment: Alignment.center),
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
                              icon: Container(
                                margin: EdgeInsets.only(right: 2),
                                child: Icon(
                                  CupertinoIcons.house_fill,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),
                              label: LocaleText(
                                "product.campaign.redirect",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget createLimitationElement(
      context, loading, campaignSnapshot, collectedCouponsSnapshot) {
    var alreadyCollected = isCouponAlreadyCollected(
        loading, campaignSnapshot, collectedCouponsSnapshot);
    if (loading ||
        !campaignSnapshot.data["coupon"]["found"] ||
        (campaignSnapshot.data["coupon"]["limitation"] == -1 &&
            !alreadyCollected)) {
      return SizedBox();
    }
    var limitation = campaignSnapshot.data["coupon"]["limitation"];
    var text = "";
    if (alreadyCollected) {
      text = Locales.string(context, "product.coupon.already.collected");
    } else if (limitation > 0) {
      text = Locales.string(context, "product.coupon.limitation.open")
          .replaceAll("%s", limitation.toString());
    } else {
      text = Locales.string(context, "product.coupon.limitation.reached");
    }
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 20),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  bool isCouponUsable(loading, campaignSnapshot, collectedCouponsSnapshot) {
    if (campaignSnapshot.data["coupon"]["limitation"] == 0) {
      return false;
    }
    if (isCouponAlreadyCollected(
        loading, campaignSnapshot, collectedCouponsSnapshot)) {
      return false;
    }
    return true;
  }

  bool isCouponAlreadyCollected(
      loading, campaignSnapshot, collectedCouponsSnapshot) {
    if (loading) {
      return false;
    }
    var coupons = collectedCouponsSnapshot.data == null
        ? []
        : jsonDecode(collectedCouponsSnapshot.data);
    return coupons.contains(campaignSnapshot.data["coupon"]["couponId"]);
  }

  Future<dynamic> findCampaign(context) async {
    var body = <String, Object>{"campaign": widget.campaign};
    var response =
        await Request.post(url: "/user/campaign/", body: body).send(context);
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
    viewedCampaigns.add(widget.campaign);
    await storage.write(
        key: "viewedCampaigns", value: jsonEncode(viewedCampaigns));
    widget.callback?.call();
  }
}
