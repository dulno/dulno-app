import 'package:dulno/product/base/navigator.dart';
import 'package:flutter/material.dart';
import 'package:dulno/product/base/header.dart';

class ProductPage extends StatelessWidget {
  ProductPage({super.key, required this.content});

  final content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProductHeader(),
      bottomNavigationBar: ProductNavigator(),
      body: content
    );
  }
}