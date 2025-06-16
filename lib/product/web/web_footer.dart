import 'package:dulno/product/web/web_download_area.dart';
import 'package:dulno/product/web/web_legal_banner.dart';
import 'package:flutter/cupertino.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          WebDownloadArea(),
          WebLegalBanner(),
        ],
      ),
    );
  }
}
