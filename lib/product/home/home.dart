import 'package:dulno/product/base/page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductPage(content: Center(child: Text("Test")));
  }
}
