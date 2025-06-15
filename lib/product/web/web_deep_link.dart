import 'package:universal_html/html.dart' as html;

class WebDeepLink {
  String url;

  WebDeepLink({required this.url});

  void open() async {
    html.AnchorElement(href: url)
      ..target = "_self"
      ..click();
  }
}
