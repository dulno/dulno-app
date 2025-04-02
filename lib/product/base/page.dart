import 'package:dulno/product/base/header.dart';
import 'package:dulno/product/base/navigator.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  ProductPage({super.key, required this.content});

  final content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProductHeader(),
      bottomNavigationBar: ProductNavigator(),
      body: content,
      floatingActionButton: Container(
        height: 70,
        width: 70,
        margin: EdgeInsets.only(bottom: 10), // Adjust for better visual effect
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white, // White border color
            width: 4, // Adjust width of the border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Shadow color
              blurRadius: 10, // Adjust the blur radius
              offset: Offset(0, 0), // Horizontal and vertical offset of the shadow
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue,
          elevation: 5,
          shape: CircleBorder(),
          child: Icon(Icons.adb, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
