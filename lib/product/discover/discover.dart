import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/base/page_body.dart';
import 'package:flutter/material.dart';

class DiscoverBody extends ProductPageBody {
  DiscoverBody({super.key})
      : super(name: "product.discover.label", icon: Icon(Icons.location_pin));

  @override
  Widget content(BuildContext context) {
    return Center(child: Text("Discover"));
  }
}
