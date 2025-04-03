import 'dart:math';

import 'package:dulno/product/base/header.dart';
import 'package:dulno/product/base/navigator.dart';
import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/card/card_list_body.dart';
import 'package:dulno/product/discover/discover_body.dart';
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
      floatingActionButton: ShiningFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class ShiningFAB extends StatefulWidget {
  @override
  _ShiningFABState createState() => _ShiningFABState();
}

class _ShiningFABState extends State<ShiningFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double glowValue = sin(_controller.value * pi);
        return Container(
          height: 90,
          width: 90,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.6 * glowValue),
                blurRadius: 20 * glowValue,
                spreadRadius: 5 * glowValue,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Color.lerp(Color(0xFF316DBC), Color(0xFF207EFA), glowValue),
            shape: CircleBorder(),
            child: Image.asset('assets/images/logo-light.png', width: 65),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}