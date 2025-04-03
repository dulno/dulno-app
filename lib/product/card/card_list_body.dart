import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/card/card_element.dart';
import 'package:flutter/material.dart';

class CardListBody extends ProductPageBody {
  CardListBody({super.key})
      : super(name: "product.card.list.label", icon: Icon(Icons.wallet));

  @override
  Widget content(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 20, bottom: 75),
        child: Column(
          children: [
            ProductCardElement(content: {}),
            const SizedBox(height: 20),
            ProductCardElement(content: {}),
            const SizedBox(height: 20),
            ProductCardElement(content: {}),
            const SizedBox(height: 20),
            ProductCardElement(content: {}),
            const SizedBox(height: 20),
            ProductCardElement(content: {}),
            const SizedBox(height: 20),
            ProductCardElement(content: {}),
          ],
        ),
      ),
    );
  }
}
