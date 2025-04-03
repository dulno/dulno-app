import 'package:flutter/material.dart';

class ProductCardElement extends StatelessWidget {
  const ProductCardElement({super.key, required this.content});

  final Map<String, Object> content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 350,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: List.generate(
                  10,
                  (index) => Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: index < 3 ? Colors.black : Colors.transparent,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
