import 'dart:convert';
import 'dart:io';

import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProductCardElement extends StatelessWidget {
  const ProductCardElement({super.key, required this.content});

  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    var foregroundColor = parseColor("cardForegroundColor");
    var backgroundColor = parseColor("cardBackgroundColor");
    return FutureBuilder<dynamic>(
      future: findCardLogo(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: backgroundColor,
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
                height: 140,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: snapshot.data == null ?
                        Container() : Image.memory(snapshot.data, height: 75,),
                    ),
                    Align(
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
                              color: index < content["stamps"]
                                  ? foregroundColor
                                  : Colors.transparent,
                              border:
                                  Border.all(color: foregroundColor, width: 3),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color parseColor(String key) {
    var hex = content[key].toString();
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future findCardLogo() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(path.join(dir.path, 'dulno', content["logoId"]));
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    var body = <String, Object>{"card": content["cardId"]};
    var response =
        await Request.post(url: "/user/card/logo/", body: body).send();
    var responseBody = jsonDecode(response.body);
    var logoId = responseBody["logoId"];
    var logo = base64Decode(responseBody["logo"]);
    final folder = Directory(path.join(dir.path, 'dulno'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final newFile = File(path.join(folder.path, logoId));
    await newFile.writeAsBytes(logo);
    return logo;
  }
}
