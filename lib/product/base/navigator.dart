import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductNavigator extends StatelessWidget implements PreferredSizeWidget {
  ProductNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.account_circle, size: 40),
          color: Color(0xFFEDEDED),
          onPressed: () {

          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}