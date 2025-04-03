import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/base/page_body.dart';
import 'package:flutter/material.dart';

class CardListBody extends ProductPageBody {
  CardListBody({super.key})
      : super(name: "product.card.list.label", icon: Icon(Icons.wallet));

  @override
  Widget content(BuildContext context) {
    return Center(child: Text("Cards"));
  }
}
