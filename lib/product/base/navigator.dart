import 'package:flutter/material.dart';

class ProductNavigator extends StatelessWidget implements PreferredSizeWidget {
  ProductNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1), // Top Border
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Color(0xFFEDEDED),
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle), // Empty space for floating button
            label: "Stamp",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
