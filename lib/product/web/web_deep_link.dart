import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;
import 'package:url_launcher/url_launcher.dart';

class WebDeepLink {
  String url;

  WebDeepLink({required this.url});

  void open() async {
    //js.context.callMethod('eval', ['window.location.href = "$url";']);
    await launchUrl(Uri.parse(url));
  }
}