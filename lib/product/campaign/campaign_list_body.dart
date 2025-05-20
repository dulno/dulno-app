import 'dart:convert';

import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/campaign/campaign_element.dart';
import 'package:dulno/product/campaign/campaign_page.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class CampaignListBody extends ProductPageBody {
  const CampaignListBody({super.key})
      : super(
            name: "product.campaign.list.label",
            unselectedIcon: CupertinoIcons.bell,
            selectedIcon: CupertinoIcons.bell_fill);

  @override
  Widget content(BuildContext context) {
    return CampaignListBodyContent();
  }
}

class CampaignListBodyContent extends StatefulWidget {
  const CampaignListBodyContent({super.key});

  @override
  State<CampaignListBodyContent> createState() =>
      _CampaignListBodyContentState();
}

class _CampaignListBodyContentState extends State<CampaignListBodyContent> {
  bool _loaded = false;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _campaigns = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> refresh() async {
    await fetchCampaigns(false);
  }

  Future<void> fetchCampaigns(reloadAfterwards) async {
    var response = await Request.get(url: "/user/campaigns/").send();
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody.isEmpty) {
      return;
    }
    _campaigns = responseBody["campaigns"];
    if (reloadAfterwards && mounted) {
      setState(() {});
    }
  }

  Future<Widget> createCampaignElements() async {
    if (!_loaded) {
      await fetchCampaigns(true);
      setState(() {
        _loaded = true;
      });
    }
    if (_campaigns.isEmpty) {
      return Center(
        child: LocaleText("product.campaign.list.empty"),
      );
    }
    /*_campaigns.sort(
        (a, b) => (b["lastUpdate"] as num).compareTo(a["lastUpdate"] as num));*/
    var elements = <Widget>[];
    for (var campaign in _campaigns) {
      elements.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CampaignPage(
                  partner: campaign["partner"]["id"],
                  campaign: campaign["id"],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: CampaignElement(
              key: ValueKey(campaign["id"].toString()),
              isLoading: false,
              content: campaign,
            ),
          ),
        ),
      );
    }
    if (elements.isEmpty) {
      elements.add(
        LocaleText(
          "product.campaign.list.empty",
          textAlign: TextAlign.center,
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
        ),
        controller: _scrollController,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 75, top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: 360,
            child: Column(
              children: [...elements],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: FutureBuilder<Widget>(
        future: createCampaignElements(),
        builder: (context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_loaded) {
            return Center(
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 75, top: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: CampaignElement(
                        isLoading: true,
                        content: {},
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: CampaignElement(
                        isLoading: true,
                        content: {},
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return snapshot.data ?? SizedBox.shrink();
        },
      ),
    );
  }
}
