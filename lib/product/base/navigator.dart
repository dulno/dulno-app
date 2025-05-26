import 'package:dulno/product/base/page_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class ProductNavigator extends StatefulWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) updateIndex;
  final List<ProductPageBody> pageBodies;

  const ProductNavigator(
      {super.key,
      required this.selectedIndex,
      required this.updateIndex,
      required this.pageBodies});

  @override
  State<ProductNavigator> createState() => _ProductNavigatorState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProductNavigatorState extends State<ProductNavigator> {
  Map<int, int> notificationCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadNotifications(context);
      for (var i = 0; i < widget.pageBodies.length; i++) {
        var pageBody = widget.pageBodies[i];
        pageBody.navigatorCallback = () {
          pageBody.notifications(context).then((count) {
            setState(() {
              notificationCounts[i] = count;
            });
          });
        };
      }
    });
  }

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
            currentIndex: widget.selectedIndex,
            onTap: widget.updateIndex,
            unselectedFontSize: 10,
            selectedFontSize: 10,
            items: navigationBarItems(context),
          ),
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width /
                (widget.pageBodies.length + 1) *
                widget.selectedIndex,
            width: MediaQuery.of(context).size.width /
                (widget.pageBodies.length + 1),
            child: Container(
              height: 2,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void loadNotifications(context) {
    for (var i = 0; i < widget.pageBodies.length; i++) {
      widget.pageBodies[i].notifications(context).then((count) {
        setState(() {
          notificationCounts[i] = count;
        });
      });
    }
  }

  List<BottomNavigationBarItem> navigationBarItems(BuildContext context) {
    List<BottomNavigationBarItem> items = [];
    var currentPage = widget.selectedIndex > 2
        ? widget.selectedIndex - 1
        : widget.selectedIndex;
    for (var i = 0; i < widget.pageBodies.length; i++) {
      var body = widget.pageBodies[i];
      bool isSelected = currentPage == i;
      final count = notificationCounts[i];
      List<Widget> iconChildren = [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: (count != null && count > 9) ? 5 : 0),
          child: Icon(
            isSelected ? body.selectedIcon : body.unselectedIcon,
            size: 30,
          ),
        ),
      ];
      if (count != null && count > 0) {
        iconChildren.add(createNotificationBadge(count));
      }
      items.add(BottomNavigationBarItem(
        icon: Stack(children: iconChildren),
        label: Locales.string(context, body.name),
      ));
    }
    items.insert(items.length ~/ 2,
        const BottomNavigationBarItem(icon: SizedBox.shrink(), label: ""));
    return items;
  }

  Widget createNotificationBadge(count) {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: count < 10 ? 16 : null,
        height: 16,
        padding: count < 10
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1)),
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            height: 1, // helps vertically center text
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
