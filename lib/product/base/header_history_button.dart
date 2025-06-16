import 'package:dulno/product/scan/scan_history_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeaderHistoryButton extends StatefulWidget
    implements PreferredSizeWidget {
  const HeaderHistoryButton({super.key});

  @override
  State<HeaderHistoryButton> createState() => _HeaderAccountButtonState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderAccountButtonState extends State<HeaderHistoryButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: IconButton(
        icon: Icon(CupertinoIcons.list_bullet, size: 30),
        color: const Color(0xFFB3B3B3),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanHistoryPage(),
            ),
          );
        },
      ),
    );
  }
}
