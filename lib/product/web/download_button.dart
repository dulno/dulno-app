import 'dart:async';
import 'dart:math';

import 'package:dulno/alert/loader_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;

class DownloadButton extends StatefulWidget {
  const DownloadButton({super.key});

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double glowValue = sin(_controller.value * pi);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.6 * min(glowValue + 0.5, 1)),
                blurRadius: 15 * (glowValue + 0.5),
                spreadRadius: 4 * (glowValue + 0.5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              download(context);
            },
            backgroundColor:
                Color.lerp(Color(0xFF37479F), Color(0xFF495ED3), glowValue),
            shape: CircleBorder(),
            child: Icon(
              CupertinoIcons.arrow_down_to_line_alt,
            ),
          ),
        );
      },
    );
  }

  void download(context) async {
    LoaderAlert().show(context);
    const deepLink = "dulno://app";
    const iosAppStoreUrl = "https://apps.apple.com/de/app/dulno/id6745476292";
    const androidPlayStoreUrl =
        "https://play.google.com/store/apps/details?id=com.dulno";
    await Clipboard.setData(ClipboardData(text: "MBVOuNybk0Lh6JBMAXg9"));
    bool appOpened = false;
    html.document.onVisibilityChange.listen((event) {
      if (html.document.hidden ?? false) {
        appOpened = true;
      }
    });
    openDeepLink(deepLink);
    Timer(
      const Duration(seconds: 2),
      () async {
        if (appOpened) {
          return;
        }
        final userAgent = html.window.navigator.userAgent.toLowerCase();
        if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
          html.window.location.href = iosAppStoreUrl;
        } else if (userAgent.contains('android')) {
          html.window.location.href = androidPlayStoreUrl;
        }
      },
    );
  }

  void openDeepLink(String url) {
    js.context.callMethod('eval', ['window.location.href = "$url";']);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
