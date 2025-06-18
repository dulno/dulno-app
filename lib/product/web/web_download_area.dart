import 'dart:async';
import 'dart:math';

import 'package:dulno/alert/loader_alert.dart';
import 'package:dulno/localization/locale_text.dart';
import 'package:dulno/localization/locales.dart';
import 'package:dulno/product/web/web_deep_link.dart';
import 'package:dulno/product/web/web_transmission.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

class WebDownloadArea extends StatefulWidget {
  const WebDownloadArea({super.key});

  @override
  State<WebDownloadArea> createState() => _WebDownloadAreaState();
}

class _WebDownloadAreaState extends State<WebDownloadArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 25, right: 25, top: 28, bottom: 18),
      width: 410,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 27,
                    ),
                    children: [
                      TextSpan(
                        text: Locales.string(
                            context, "product.web.download.description.1"),
                        style: TextStyle(color: Colors.indigo),
                      ),
                      TextSpan(
                        text: Locales.string(
                            context, "product.web.download.description.2"),
                      ),
                      TextSpan(
                        text: Locales.string(
                            context, "product.web.download.description.3"),
                        style: TextStyle(color: Colors.indigo),
                      ),
                      TextSpan(
                        text: "!",
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    LocaleText(
                      "product.web.download.app",
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      CupertinoIcons.arrow_right,
                      size: 18,
                    ),
                  ],
                )
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double glowValue = sin(_controller.value * pi);
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo
                          .withOpacity(0.8 * min(glowValue + 0.5, 1)),
                      blurRadius: 15 * (glowValue + 0.5),
                      spreadRadius: 4 * (glowValue + 0.5),
                    ),
                  ],
                ),
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  onPressed: () {
                    download(context);
                  },
                  backgroundColor: Color.lerp(
                      Color(0xFF37479F), Color(0xFF495ED3), glowValue),
                  shape: CircleBorder(),
                  child: Icon(
                    CupertinoIcons.arrow_down_to_line_alt,
                    size: 35,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void download(context) async {
    LoaderAlert().show(context);
    String? transmission = await WebTransmission().request(context);
    if (transmission == null) {
      return;
    }
    bool appOpened = false;
    html.document.onVisibilityChange.listen((event) {
      if (html.document.hidden ?? false) {
        appOpened = true;
      }
    });
    WebDeepLink(url: "dulno://transmission?id=$transmission").open();
    Timer(
      const Duration(seconds: 1),
      () async {
        if (appOpened) {
          return;
        }
        await Clipboard.setData(ClipboardData(text: transmission));
        const iosAppStoreUrl =
            "https://apps.apple.com/de/app/dulno/id6745476292";
        const androidPlayStoreUrl =
            "https://play.google.com/store/apps/details?id=com.dulno";
        final userAgent = html.window.navigator.userAgent.toLowerCase();
        if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
          html.window.location.href = iosAppStoreUrl;
        } else if (userAgent.contains('android')) {
          html.window.location.href = androidPlayStoreUrl;
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
