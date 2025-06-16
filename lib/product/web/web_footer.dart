import 'package:dulno/product/web/web_download_area.dart';
import 'package:dulno/product/web/web_legal_banner.dart';
import 'package:flutter/cupertino.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              WebDownloadArea(),
              WebLegalBanner(),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: -60,
          height: 60,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFAFAFA).withOpacity(0.0),
                    Color(0xFFFAFAFA).withOpacity(0.75),
                    Color(0xFFFAFAFA),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
