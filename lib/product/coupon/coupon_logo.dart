import 'dart:convert';
import 'dart:io';

import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CouponLogo {
  final String? couponId;
  final String? currentLogoId;
  Widget? logo;

  CouponLogo({required this.couponId, required this.currentLogoId});

  Future fetch() async {
    if (couponId == null || currentLogoId == null) {
      return null;
    }
    if (logo != null) {
      return logo;
    }
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(path.join(dir.path, 'dulno/coupon'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final file =
        File(path.join(dir.path, 'dulno/coupon', "$couponId-$currentLogoId"));
    if (await file.exists()) {
      logo = Image.memory(await file.readAsBytes(), fit: BoxFit.contain);
      return logo;
    }
    var body = <String, Object>{"coupon": couponId!};
    var response =
        await Request.post(url: "/user/coupon/logo/", body: body).send();
    if (response == null || response.statusCode == 409) {
      logo = SizedBox.shrink();
      return logo;
    }
    var responseBody = jsonDecode(response.body);
    var newLogoId = responseBody["logoId"];
    var newLogo = base64Decode(responseBody["logo"]);
    final files = folder.listSync();
    for (var file in files) {
      if (file is File && file.path.contains(couponId!)) {
        await file.delete();
      }
    }
    final newFile = File(path.join(folder.path, "$couponId-$newLogoId"));
    await newFile.writeAsBytes(newLogo);
    logo = Image.memory(newLogo, fit: BoxFit.contain);
    return logo;
  }
}
