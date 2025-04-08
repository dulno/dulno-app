import 'package:dulno/product/profile/profile_page.dart';
import 'package:flutter/material.dart';

class ProductHeader extends StatelessWidget implements PreferredSizeWidget {
  const ProductHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Image.asset('assets/images/logo-header.png', width: 120),
      centerTitle: true,
      actions: <Widget>[
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 40),
              color: const Color(0xFFB3B3B3),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
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
