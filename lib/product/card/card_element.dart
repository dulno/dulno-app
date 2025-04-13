import 'dart:convert';
import 'dart:io';

import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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
      return createStampCardContent(foregroundColor, content["stampIcon"]);
    } else if (type == "MEMBER") {
      return createMemberCardContent(foregroundColor, content["memberIcon"]);
    }
    return Container();
  }

  Widget createStampCardContent(foregroundColor, stampIcon) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: List.generate(
          10,
          (index) => Skeleton.leaf(
            child: SizedBox(
              width: 30,
              height: 30,
              child: FaIcon(
                parseIcon(
                    stampIcon, index < content["stamps"] ? "solid" : "regular"),
                size: 30,
                color: foregroundColor,
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

  Widget createMemberCardContent(foregroundColor, memberIcon) {
    return Align(
      alignment: Alignment.center,
      child: FaIcon(
        parseIcon(memberIcon, "solid"),
        size: 56,
        color: foregroundColor,
      ),
    );
  }

  IconData parseIcon(name, style) {
    if (name == "circle" && style == "regular") {
      return FontAwesomeIcons.circle;
    } else if (name == "circle" && style == "solid") {
      return FontAwesomeIcons.solidCircle;
    } else if (name == "square" && style == "regular") {
      return FontAwesomeIcons.square;
    } else if (name == "square" && style == "solid") {
      return FontAwesomeIcons.solidSquare;
    } else if (name == "star" && style == "regular") {
      return FontAwesomeIcons.star;
    } else if (name == "star" && style == "solid") {
      return FontAwesomeIcons.solidStar;
    } else if (name == "heart" && style == "regular") {
      return FontAwesomeIcons.heart;
    } else if (name == "heart" && style == "solid") {
      return FontAwesomeIcons.solidHeart;
    } else if (name == "face-smile" && style == "regular") {
      return FontAwesomeIcons.faceSmile;
    } else if (name == "face-smile" && style == "solid") {
      return FontAwesomeIcons.solidFaceSmile;
    } else if (name == "bell" && style == "regular") {
      return FontAwesomeIcons.bell;
    } else if (name == "bell" && style == "solid") {
      return FontAwesomeIcons.solidBell;
    } else if (name == "thumbs-up" && style == "regular") {
      return FontAwesomeIcons.thumbsUp;
    } else if (name == "thumbs-up" && style == "solid") {
      return FontAwesomeIcons.solidThumbsUp;
    } else if (name == "bookmark" && style == "regular") {
      return FontAwesomeIcons.bookmark;
    } else if (name == "bookmark" && style == "solid") {
      return FontAwesomeIcons.solidBookmark;
    } else if (name == "gem" && style == "regular") {
      return FontAwesomeIcons.gem;
    } else if (name == "gem" && style == "solid") {
      return FontAwesomeIcons.solidGem;
    } else if (name == "crown" && style == "solid") {
      return FontAwesomeIcons.crown;
    } else if (name == "circle-user" && style == "solid") {
      return FontAwesomeIcons.solidCircleUser;
    }
    return FontAwesomeIcons.circle;
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
    final file =
        File(path.join(dir.path, 'dulno/card', "$cardId-$currentLogoId"));
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    var body = <String, Object>{"card": cardId};
    var response =
        await Request.post(url: "/user/card/logo/", body: body).send();
    if (response == null || response.statusCode == 409) {
      return SizedBox.shrink();
    }
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
