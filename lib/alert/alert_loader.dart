import 'package:flutter/material.dart';

class AlertLoader extends StatefulWidget {
  AlertLoader({super.key});

  @override
  State<AlertLoader> createState() => _AlertLoaderState();

  show(context) {
    showDialog(context: context, builder: (BuildContext context) => this);
  }
}

class _AlertLoaderState extends State<AlertLoader> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      content: SizedBox(
        height: 100,
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 4,
            ),
          ),
        ),
      ),
    );
  }
}
