import 'package:dulno/product/base/header.dart';
import 'package:dulno/product/base/navigator.dart';
import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/campaign/campaign_list_body.dart';
import 'package:dulno/product/card/card_list_body.dart';
import 'package:dulno/product/coupon/coupon_list_body.dart';
import 'package:dulno/product/partner/discover_body.dart';
import 'package:dulno/product/scan/scan_button.dart';
import 'package:dulno/product/web/web_footer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  int? initialPageIndex = 0;

  ProductPage({super.key, this.initialPageIndex});

  @override
  State<ProductPage> createState() => ProductPageState();
}

class ProductPageState extends State<ProductPage> {
  final List<ProductPageBody> pageBodies = [
    CardListBody(),
    CouponListBody(),
    CampaignListBody(),
    DiscoverBody()
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPageIndex ?? 0;
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        signInCallback: () => findCardListBody().refresh(context),
      ),
      bottomNavigationBar: !kIsWeb
          ? ProductNavigator(
              selectedIndex: _selectedIndex,
              updateIndex: _onItemTapped,
              pageBodies: pageBodies)
          : WebFooter(),
      body: pageBodies[_selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex]
          .content(context),
      backgroundColor: Color(0xFFFAFAFA),
      floatingActionButton: !kIsWeb
          ? ScanButton(
              callback: findCardListBody().reload,
              currentPageIndex: () => _selectedIndex,
            )
          : SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  CardListBody findCardListBody() {
    return pageBodies[0] as CardListBody;
  }
}
