import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;

class WebDeepLink {
  String url;

  WebDeepLink({required this.url});

  void open() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
      final iframe = html.IFrameElement()
        ..style.display = 'none'
        ..src = url;
      html.document.body?.append(iframe);
    } else if (userAgent.contains('android')) {
      js.context.callMethod('eval', ['window.location.href = "$url";']);
    }
  }
}
