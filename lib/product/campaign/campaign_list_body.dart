import 'package:dulno/product/base/page_body.dart';
import 'package:flutter/cupertino.dart';

class CampaignListBody extends ProductPageBody {
  final GlobalKey<_CampaignListBodyContentState> _key =
      GlobalKey<_CampaignListBodyContentState>();

  CampaignListBody({super.key})
      : super(
            name: "product.campaign.list.label",
            unselectedIcon: CupertinoIcons.bell,
            selectedIcon: CupertinoIcons.bell_fill);

  @override
  Widget content(BuildContext context) {
    return CampaignListBodyContent(key: _key);
  }
}

class CampaignListBodyContent extends StatefulWidget {
  const CampaignListBodyContent({super.key});

  @override
  State<CampaignListBodyContent> createState() =>
      _CampaignListBodyContentState();
}

class _CampaignListBodyContentState extends State<CampaignListBodyContent> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
