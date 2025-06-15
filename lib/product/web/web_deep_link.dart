import 'dart:async';

import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class WebDeepLink {
  String url;

  WebDeepLink({required this.url});

  void open() async {
    html.window.location.assign(url);
    Timer(
      const Duration(seconds: 2),
      () async {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
    );
  }
}
