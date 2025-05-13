import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class Alert extends StatefulWidget {
  final IconData icon;
  String? description;
  Widget? content;
  bool? cancelButton;
  String? cancelButtonText;
  Color? cancelButtonColor;
  String? confirmButtonText;
  Color? confirmButtonColor;
  bool Function()? confirmButtonEnabled;
  Function()? callback;

  Alert(
      {super.key,
      required this.icon,
      this.description,
      this.content,
      this.cancelButton,
      this.cancelButtonText,
      this.cancelButtonColor,
      this.confirmButtonText,
      this.confirmButtonColor,
      this.confirmButtonEnabled,
      this.callback});

  @override
  State<Alert> createState() => AlertState();

  show(context) {
    showDialog(context: context, builder: (BuildContext context) => this);
  }
}

class AlertState extends State<Alert> {
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var confirmationDisabled =
        widget.confirmButtonEnabled != null && !widget.confirmButtonEnabled!();
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
          widget.description != null
              ? Container(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                  child: LocaleText(
                    widget.description ?? "",
                    textAlign: TextAlign.center,
                  ),
                )
              : widget.content ?? SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.cancelButton == true
                  ? Container(
                      margin: EdgeInsets.only(top: 15, bottom: 15, right: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              widget.cancelButtonColor ?? Colors.grey),
                          shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)))),
                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10)),
                          minimumSize: WidgetStateProperty.all(Size(0, 0)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: LocaleText(
                            widget.cancelButtonText ?? "alert.cancel",
                            style:
                                TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    )
                  : SizedBox.shrink(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: ElevatedButton(
                  onPressed: () {
                    if (confirmationDisabled) {
                      return;
                    }
                    Navigator.pop(context);
                    widget.callback?.call();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        confirmationDisabled
                            ? widget.confirmButtonColor ?? Colors.indigo[200]
                            : widget.confirmButtonColor ?? Colors.indigo),
                    shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)))),
                    padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                    minimumSize: WidgetStateProperty.all(Size(0, 0)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
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
