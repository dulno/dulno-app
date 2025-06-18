import 'package:dulno/product/card/card_animation.dart';
import 'package:dulno/product/card/card_logo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CardElement extends StatefulWidget {
  final bool isLoading;
  final Map<String, dynamic> content;
  final bool animateLastStamp;
  final bool animateCard;

  const CardElement(
      {super.key,
      required this.isLoading,
      required this.content,
      required this.animateLastStamp,
      required this.animateCard});

  @override
  State<CardElement> createState() => _CardElementState();
}

class _CardElementState extends State<CardElement> {
  late CardLogo _logo;
  late Future _logoFetch;

  @override
  void initState() {
    super.initState();
    _logo = CardLogo(
        cardId: widget.content["cardId"],
        currentLogoId: widget.content["logoId"]);
    _logoFetch = _logo.fetch(context);
  }

  @override
  Widget build(BuildContext context) {
    var element = createCardElement();
    if (widget.animateCard) {
      return CardBlinkerAnimation(
        color: Colors.grey[400]!,
        scale: 1.05,
        child: element,
      );
    }
    return element;
  }

  Widget createCardElement() {
    var foregroundColor =
        widget.isLoading ? Colors.black : parseColor("cardForegroundColor");
    var backgroundColor =
        widget.isLoading ? Colors.white : parseColor("cardBackgroundColor");
    return FutureBuilder<dynamic>(
      future: _logoFetch,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Skeletonizer(
          enabled: widget.isLoading,
          child: Container(
            width: 360,
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
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: (_logo.logo == null || widget.isLoading)
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
                            : Container(
                                constraints: BoxConstraints(
                                  maxWidth: 135,
                                  maxHeight: 75,
                                ),
                                child: _logo.logo!,
                              ),
                      ),
                      widget.isLoading
                          ? Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(top: 100),
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
    var type = widget.content["cardType"];
    if (type == "COLLECTION" || type == "VALUE") {
      return createStampCardContent(
          foregroundColor, widget.content["stampIcon"]);
    } else if (type == "MEMBER") {
      return createMemberCardContent(
          foregroundColor, widget.content["memberIcon"]);
    }
    return Container();
  }

  Widget createStampCardContent(foregroundColor, stampIcon) {
    var type = widget.content["cardType"];
    var stampNumber = type == "COLLECTION"
        ? widget.content["rewardNumber"]
        : widget.content["valueNumber"];
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(top: 100, left: 5, right: 5),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: List.generate(stampNumber,
            (index) => createStampElement(foregroundColor, stampIcon, index)),
      ),
    );
  }

  Widget createStampElement(foregroundColor, stampIcon, index) {
    var stamps = widget.content["stamps"];
    var icon = parseIcon(stampIcon, index < stamps ? "solid" : "regular");
    var element = Skeleton.leaf(
      child: SizedBox(
        width: 26,
        height: 26,
        child: icon != null
            ? FaIcon(
                icon,
                size: 26,
                color: foregroundColor,
              )
            : Container(),
      ),
    );
    if (!widget.animateLastStamp) {
      return element;
    }
    var isCollection = widget.content["cardType"] == "COLLECTION";
    if (index == stamps + (isCollection ? -1 : 0)) {
      return CardBlinkerAnimation(
          child: element,
          color: isCollection ? Colors.greenAccent : Colors.redAccent);
    }
    return element;
  }

  Widget createMemberCardContent(foregroundColor, memberIcon) {
    var icon = parseIcon(memberIcon, "solid");
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 40),
      child: icon != null
          ? FaIcon(
              icon,
              size: 56,
              color: foregroundColor,
            )
          : Container(height: 40),
    );
  }

  IconData? parseIcon(name, style) {
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
    return null;
  }

  Color parseColor(String key) {
    var hex = widget.content[key].toString();
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
