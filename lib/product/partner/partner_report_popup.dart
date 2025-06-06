import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/alert/connection_alert.dart';
import 'package:dulno/alert/loader_alert.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class PartnerReportPopup {
  final String partner;

  const PartnerReportPopup({required this.partner});

  void show(context) {
    GlobalKey<_PartnerReportPopupContentState> contentKey =
        GlobalKey<_PartnerReportPopupContentState>();
    GlobalKey<AlertState> alertKey = GlobalKey<AlertState>();
    var content = _PartnerReportPopupContent(
      key: contentKey,
      alertKey: alertKey,
    );
    Alert(
      key: alertKey,
      icon: CupertinoIcons.flag,
      confirmButtonText: "product.partner.report.submit",
      content: content,
      confirmButtonEnabled: () {
        var state = contentKey.currentState;
        if (state == null) {
          return false;
        }
        return state.controller.text != "";
      },
      callback: () {
        var state = contentKey.currentState;
        if (state == null) {
          return false;
        }
        reportPartner(context, state.controller.text);
      },
    ).show(context);
  }

  Future<void> reportPartner(context, message) async {
    LoaderAlert().show(context);
    var body = <String, Object>{"partner": partner, "message": message};
    var response = await Request.post(url: "/user/partner/report/", body: body)
        .send(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null || response.statusCode == 409) {
      ConnectionAlert().show(context);
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      Alert(
        description: "product.partner.report.failure",
        type: AlertType.error,
      ).show(context);
      return;
    }
    Alert(
      description: "product.partner.report.success",
      type: AlertType.success,
    ).show(context);
  }
}

class _PartnerReportPopupContent extends StatefulWidget {
  GlobalKey<AlertState> alertKey;

  _PartnerReportPopupContent({super.key, required this.alertKey});

  @override
  State<_PartnerReportPopupContent> createState() =>
      _PartnerReportPopupContentState();
}

class _PartnerReportPopupContentState
    extends State<_PartnerReportPopupContent> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        children: [
          LocaleText(
            "product.partner.report.title",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          LocaleText("product.partner.report.description"),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller,
            onChanged: (value) {
              widget.alertKey.currentState?.reload();
              setState(() {});
            },
            minLines: 3,
            maxLines: 3,
            maxLength: 512,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.grey[500]),
              hintText: Locales.string(
                context,
                "product.partner.report.message.placeholder",
              ),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: _buildInputBorder(),
              enabledBorder: _buildInputBorder(),
              focusedBorder: _buildInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _buildInputBorder() {
    Color borderColor = controller.text != "" ? Colors.green : Colors.red;
    return OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 2.0),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
