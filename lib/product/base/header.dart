import 'package:dulno/product/base/header_account_button.dart';
import 'package:dulno/product/web/download_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final Function signInCallback;

  const Header({super.key, required this.signInCallback});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Image.asset('assets/images/logo-header.png', width: 120),
      centerTitle: true,
      actions: <Widget>[
        !kIsWeb
            ? HeaderAccountButton(signInCallback: widget.signInCallback)
            : SizedBox.shrink(),
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
}
