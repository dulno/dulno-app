import 'dart:convert';
import 'dart:io';

import 'package:dulno/product/partner/partner_link_list.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PartnerPopup extends StatefulWidget {
  final Map<String, dynamic> partner;
  final Map<String, dynamic> location;

  const PartnerPopup(
      {super.key, required this.partner, required this.location});

  @override
  State<PartnerPopup> createState() => _DraggablePopupState();
}

class _DraggablePopupState extends State<PartnerPopup> {
  double _popupHeight = 300.0;
  double _startDragHeight = 300.0;
  double _startVerticalDrag = 0.0;
  Widget? _logo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: findPartnerLogo(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          _logo = snapshot.data;
        }
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onVerticalDragStart: (details) {
              _startVerticalDrag = details.localPosition.dy;
              _startDragHeight = _popupHeight;
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                _popupHeight = _startDragHeight +
                    (_startVerticalDrag - details.localPosition.dy);
                _popupHeight = _popupHeight.clamp(100.0, 600.0);
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 50),
              height: _popupHeight,
              decoration: BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Skeletonizer(
                enabled: _logo == null,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        width: 75,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _logo == null
                                  ? Skeleton.leaf(
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 135,
                                        maxHeight: 90,
                                      ),
                                      child: _logo!,
                                    ),
                            ),
                            SizedBox(height: 40),
                            Text(
                              utf8.decode(
                                  widget.partner["name"].toString().codeUnits),
                              style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              utf8.decode(widget.partner["description"]
                                  .toString()
                                  .codeUnits),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            SizedBox(height: 30),
                            LocaleText(
                              "product.partner.popup.address",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              utf8.decode(widget.location["address"]
                                  .toString()
                                  .codeUnits),
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 20),
                            LocaleText(
                              "product.partner.popup.links",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            PartnerLinkList(partner: widget.partner),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future findPartnerLogo() async {
    if (_logo != null) {
      return _logo;
    }
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(path.join(dir.path, 'dulno/partner'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    var partnerId = widget.partner["id"];
    var currentLogoId = widget.partner["logoId"];
    final file =
        File(path.join(dir.path, 'dulno/partner', "$partnerId-$currentLogoId"));
    if (await file.exists()) {
      return Image.memory(await file.readAsBytes(), fit: BoxFit.contain);
    }
    var body = <String, Object>{"partner": partnerId};
    var response =
        await Request.post(url: "/user/partner/logo/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return SizedBox.shrink();
    }
    var responseBody = jsonDecode(response.body);
    var newLogoId = responseBody["logoId"];
    var newLogo = base64Decode(responseBody["logo"]);
    final files = folder.listSync();
    for (var file in files) {
      if (file is File && file.path.contains(partnerId)) {
        await file.delete();
      }
    }
    final newFile = File(path.join(folder.path, "$partnerId-$newLogoId"));
    await newFile.writeAsBytes(newLogo);
    return Image.memory(newLogo, fit: BoxFit.contain);
  }
}
