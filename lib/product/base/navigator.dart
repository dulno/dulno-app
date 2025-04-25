import 'package:dulno/product/base/page_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class ProductNavigator extends StatelessWidget implements PreferredSizeWidget {
  const ProductNavigator(
      {super.key,
      required this.selectedIndex,
      required this.updateIndex,
      required this.pageBodies});

  final int selectedIndex;
  final Function(int) updateIndex;
  final List<ProductPageBody> pageBodies;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: Stack(
        children: [
          BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            currentIndex: selectedIndex,
            onTap: updateIndex,
            unselectedFontSize: 14,
            selectedFontSize: 14,
            items: navigationBarItems(context),
          ),
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width /
                (pageBodies.length + 1) *
                selectedIndex,
            width: MediaQuery.of(context).size.width / (pageBodies.length + 1),
            child: Container(
              height: 2,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  List<BottomNavigationBarItem> navigationBarItems(context) {
    List<BottomNavigationBarItem> items = [];
    for (ProductPageBody body in pageBodies) {
      items.add(BottomNavigationBarItem(
        icon: body.icon,
        label: Locales.string(context, body.name),
      ));
    }
    items.insert(items.length ~/ 2,
        BottomNavigationBarItem(icon: SizedBox.shrink(), label: ""));
    return items;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
