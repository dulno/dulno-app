import 'package:flutter/material.dart';

abstract class ProductPageBody extends StatelessWidget {
  const ProductPageBody({super.key, required this.name, required this.icon});

  final String name;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return content(context);
  }

  Widget content(BuildContext context);
}
