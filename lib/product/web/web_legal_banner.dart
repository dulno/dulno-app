import 'package:dulno/product/profile/profile_footer_link.dart';
import 'package:flutter/material.dart';

class WebLegalBanner extends StatelessWidget {
  const WebLegalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: [
          ProfileFooterLink(
            text: "product.profile.imprint",
            url: "https://dulno.com/imprint/",
            fontSize: 10,
          ),
          ProfileFooterLink(
            text: "product.profile.terms.of.service",
            url: "https://dulno.com/terms-of-service/",
            fontSize: 10,
          ),
          ProfileFooterLink(
            text: "product.profile.privacy.policy",
            url: "https://dulno.com/privacy-policy/",
            fontSize: 10,
          ),
        ],
      ),
    );
  }
}
