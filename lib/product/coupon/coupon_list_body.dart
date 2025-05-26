import 'dart:convert';

import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/coupon/coupon_element.dart';
import 'package:dulno/product/coupon/coupon_list_empty.dart';
import 'package:dulno/product/coupon/coupon_page.dart';
import 'package:dulno/product/coupon/coupon_search_bar.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CouponListBody extends ProductPageBody {
  final GlobalKey<_CouponListBodyContentState> _key =
      GlobalKey<_CouponListBodyContentState>();

  CouponListBody({super.key})
      : super(
            name: "product.coupon.list.label",
            unselectedIcon: CupertinoIcons.gift,
            selectedIcon: CupertinoIcons.gift_fill);

  @override
  Widget content(BuildContext context) {
    return CouponListBodyContent(key: _key);
  }

  void reload() {
    _key.currentState?.reload();
  }

  void refresh(context) {
    _key.currentState?.refresh(context);
  }
}

class CouponListBodyContent extends StatefulWidget {
  const CouponListBodyContent({super.key});

  @override
  State<CouponListBodyContent> createState() => _CouponListBodyContentState();
}

class _CouponListBodyContentState extends State<CouponListBodyContent> {
  bool _loaded = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _coupons = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void reload() async {
    const storage = FlutterSecureStorage();
    final couponCache = await storage.read(key: "coupons");
    _coupons = couponCache == null ? [] : jsonDecode(couponCache);
    if (mounted) {
      setState(() {
        scrollToTop();
      });
    }
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> refresh(context) async {
    await fetchCoupons(context, false);
    if (mounted) {
      setState(() {
        _searchController.text = "";
      });
    }
  }

  Future<void> fetchCoupons(context, reloadAfterwards) async {
    const storage = FlutterSecureStorage();
    var body = <String, Object>{};
    final couponCache = await storage.read(key: "coupons");
    var coupons = (couponCache == null ? [] : jsonDecode(couponCache))
        .map((coupon) => coupon["redeemableId"])
        .toList();
    body["coupons"] = coupons;
    var response =
        await Request.post(url: "/user/coupons/", body: body).send(context);
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody.isEmpty) {
      return;
    }
    _coupons = responseBody["coupons"];
    await storage.write(key: "coupons", value: jsonEncode(_coupons));
    if (reloadAfterwards && mounted) {
      setState(() {});
    }
  }

  Future<Widget> createCouponElements(context, value) async {
    if (!_loaded) {
      const storage = FlutterSecureStorage();
      final couponCache = await storage.read(key: "coupons");
      _coupons = couponCache == null ? [] : jsonDecode(couponCache);
      fetchCoupons(context, true);
      setState(() {
        _loaded = true;
      });
    }
    if (_coupons.isEmpty) {
      return CouponListEmptyContent(signInCallback: () {
        refresh(context);
      });
    }
    _coupons.sort(
        (a, b) => (b["lastUpdate"] as num).compareTo(a["lastUpdate"] as num));
    var elements = <Widget>[];
    for (var coupon in _coupons) {
      if (value.toString().isEmpty ||
          coupon["partnerName"]
              .toString()
              .toLowerCase()
              .contains(value.toString().toLowerCase())) {
        elements.add(GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CouponPage(content: coupon)));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: CouponElement(
              key: ValueKey(coupon["redeemableId"].toString()),
              isLoading: false,
              content: coupon,
              state: CouponElementState.redeemable,
              unusable: false,
            ),
          ),
        ));
      }
    }
    if (elements.isEmpty) {
      elements.add(
        LocaleText(
          "product.coupon.list.empty",
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
          margin: const EdgeInsets.only(bottom: 75),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: 360,
            child: Column(
              children: [
                CouponSearchBar(
                  controller: _searchController,
                ),
                ...elements
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => refresh(context),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return FutureBuilder<Widget>(
            future: createCouponElements(context, value.text),
            builder: (context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_loaded) {
                return Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 75),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Skeletonizer(
                          child: Skeleton.leaf(
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: CouponElement(
                            isLoading: true,
                            content: {},
                            state: CouponElementState.redeemable,
                            unusable: false,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: CouponElement(
                            isLoading: true,
                            content: {},
                            state: CouponElementState.redeemable,
                            unusable: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return snapshot.data ?? SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
