import 'package:dulno/product/base/header.dart';
import 'package:dulno/product/base/navigator.dart';
import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/base/scan_button.dart';
import 'package:dulno/product/card/card_list_body.dart';
import 'package:dulno/product/partner/discover_body.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _selectedIndex = 0;
  List<ProductPageBody> pageBodies = [CardListBody(), DiscoverBody()];

  void _onItemTapped(int index) {
    if (index == 1) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProductHeader(),
      bottomNavigationBar: ProductNavigator(
          selectedIndex: _selectedIndex,
          updateIndex: _onItemTapped,
          pageBodies: pageBodies),
      body: pageBodies[_selectedIndex > 1 ? _selectedIndex - 1 : _selectedIndex]
          .content(context),
      backgroundColor: Color(0xFFFAFAFA),
      floatingActionButton: ProductScanButton(
        callback: (pageBodies[0] as CardListBody).refresh,
        currentPageIndex: () => _selectedIndex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
