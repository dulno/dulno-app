import 'dart:convert';
import 'dart:io';

import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PartnerLogo {
  final String partnerId;
  final String currentLogoId;
  Widget? logo;

  PartnerLogo({required this.partnerId, required this.currentLogoId});

  Future fetch() async {
    if (logo != null) {
      return logo;
    }
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(path.join(dir.path, 'dulno/partner'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final file =
        File(path.join(dir.path, 'dulno/partner', "$partnerId-$currentLogoId"));
    if (await file.exists()) {
      logo = Image.memory(await file.readAsBytes(), fit: BoxFit.contain);
      return logo;
    }
    var body = <String, Object>{"partner": partnerId};
    var response =
        await Request.post(url: "/user/partner/logo/", body: body).send();
    if (response == null || response.statusCode == 409) {
      logo = SizedBox.shrink();
      return logo;
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
    logo = Image.memory(newLogo, fit: BoxFit.contain);
    return logo;
  }
}
