import 'dart:convert';
import 'dart:io';

import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:skeletonizer/skeletonizer.dart';

class ProductCardElement extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic> content;

  const ProductCardElement(
      {super.key, required this.isLoading, required this.content});

  @override
  Widget build(BuildContext context) {
    var foregroundColor =
        isLoading ? Colors.black : parseColor("cardForegroundColor");
    var backgroundColor =
        isLoading ? Colors.white : parseColor("cardBackgroundColor");
    return FutureBuilder<dynamic>(
      future: findCardLogo(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Skeletonizer(
          enabled: isLoading,
          child: Container(
            padding: const EdgeInsets.all(12),
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
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: (snapshot.data == null || isLoading)
                            ? Skeleton.leaf(
                                child: Container(
                                  height: 75,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              )
                            : Image.memory(snapshot.data, height: 75),
                      ),
                      isLoading
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Skeleton.leaf(
                                child: Container(
                                  width: double.infinity,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    // This helps even in non-skeleton mode
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            )
                          : createCardContent(foregroundColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget createCardContent(foregroundColor) {
    var type = content["cardType"];
    if (type == "COLLECTION" || type == "VALUE") {
      return createStampCardContent(foregroundColor);
    } else if (type == "MEMBER") {
      return createMemberCardContent(foregroundColor);
    }
    return Container();
  }

  Widget createStampCardContent(foregroundColor) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: List.generate(
          10,
          (index) => Skeleton.leaf(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: stampFillColor(index, foregroundColor),
                border: Border.all(color: foregroundColor, width: 3),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color stampFillColor(index, foregroundColor) {
    if (isLoading) {
      return Colors.transparent;
    }
    if (index < content["stamps"]) {
      return foregroundColor;
    }
    return Colors.transparent;
  }

  Widget createMemberCardContent(foregroundColor) {
    return Align(
      alignment: Alignment.center,
      child: FaIcon(FontAwesomeIcons.crown, size: 56, color: foregroundColor),
    );
  }

  Color parseColor(String key) {
    var hex = content[key].toString();
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future findCardLogo() async {
    if (isLoading) {
      return null;
    }
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(path.join(dir.path, 'dulno/card'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    var cardId = content["cardId"];
    var currentLogoId = content["logoId"];
    final file = File(path.join(dir.path, 'dulno/card', "$cardId-$currentLogoId"));
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    var body = <String, Object>{"card": cardId};
    var response =
        await Request.post(url: "/user/card/logo/", body: body).send();
    var responseBody = jsonDecode(response.body);
    var newLogoId = responseBody["logoId"];
    var newLogo = base64Decode(responseBody["logo"]);
    final files = folder.listSync();
    for (var file in files) {
      if (file is File && file.path.contains(cardId)) {
        await file.delete();
      }
    }
    final newFile = File(path.join(folder.path, "$cardId-$newLogoId"));
    await newFile.writeAsBytes(newLogo);
    return newLogo;
  }
}
