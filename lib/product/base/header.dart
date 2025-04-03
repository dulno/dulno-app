import 'package:dulno/product/profile/profile.dart';
import 'package:flutter/material.dart';

class ProductHeader extends StatelessWidget implements PreferredSizeWidget {
  const ProductHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFEDEDED),
      surfaceTintColor: Colors.transparent,
      title: Image.asset('assets/images/logo-header.png', width: 120),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.account_circle, size: 40),
          color: Color(0xFFB3B3B3),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage()));
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Container(
          color: Colors.black12,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
