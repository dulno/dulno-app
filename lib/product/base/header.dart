import 'package:dulno/product/profile/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductHeader extends StatefulWidget implements PreferredSizeWidget {
  final Function signInCallback;

  const ProductHeader({super.key, required this.signInCallback});

  @override
  State<ProductHeader> createState() => _ProductHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProductHeaderState extends State<ProductHeader> {
  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    return FutureBuilder<String?>(
      future: storage.read(key: "email"),
      builder: (context, AsyncSnapshot<String?> email) {
        return AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Image.asset('assets/images/logo-header.png', width: 120),
          centerTitle: true,
          actions: <Widget>[
            Stack(
              children: [
                IconButton(
                  icon: Icon(CupertinoIcons.person_crop_circle_fill, size: 40),
                  color: const Color(0xFFB3B3B3),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          signInCallback: () {
                            widget.signInCallback();
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
                email.data == null || email.data == ""
                    ? Positioned(
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
                      )
                    : SizedBox.shrink(),
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
      },
    );
  }
}
