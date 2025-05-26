import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class CouponSearchBar extends StatefulWidget {
  final TextEditingController controller;

  const CouponSearchBar({super.key, required this.controller});

  @override
  State<CouponSearchBar> createState() => _CouponSearchBarState();
}

class _CouponSearchBarState extends State<CouponSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: widget.controller,
        builder: (context, value, child) {
          return TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.grey[500]),
              hintText: Locales.string(context, "product.coupon.list.search"),
              prefixIcon: Icon(Icons.search),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          );
        },
      ),
    );
  }
}
