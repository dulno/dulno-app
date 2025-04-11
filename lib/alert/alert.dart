import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class Alert extends StatefulWidget {
  final String description;
  final IconData icon;
  bool? cancelButton;
  String? cancelButtonText;
  String? confirmButtonText;
  Function()? callback;

  Alert(
      {super.key,
      required this.description,
      required this.icon,
      this.cancelButton,
      this.cancelButtonText,
      this.confirmButtonText,
      this.callback});

  @override
  State<Alert> createState() => _AlertState();

  show(context) {
    showDialog(context: context, builder: (BuildContext context) => this);
  }
}

class _AlertState extends State<Alert> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      contentPadding: const EdgeInsets.only(top: 10),
      title: Center(
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          child: Icon(widget.icon, size: 35, color: Colors.black),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
            child: LocaleText(
              widget.description,
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.cancelButton == true
                  ? Container(
                      margin: EdgeInsets.only(top: 15, bottom: 15, right: 10),
                      width: 90,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.grey),
                            shape: WidgetStateProperty.all(
                                const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5.0)))),
                            padding: WidgetStateProperty.all(EdgeInsets.zero)),
                        child: LocaleText(widget.cancelButtonText ?? "alert.cancel",
                            style:
                                TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    )
                  : SizedBox.shrink(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                width: 40,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.callback?.call();
                  },
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                      shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)))),
                      padding: WidgetStateProperty.all(EdgeInsets.zero)),
                  child: LocaleText(widget.confirmButtonText ?? "alert.ok",
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
