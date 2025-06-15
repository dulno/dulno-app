import 'package:universal_html/js.dart' as js;

class WebDeepLink {
  String url;

  WebDeepLink({required this.url});

  void open() {
    js.context.callMethod('eval', ['window.location.href = "$url";']);
  }
}