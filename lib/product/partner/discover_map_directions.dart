import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class DiscoverMapDirections {
  final double destinationLatitude;
  final double destinationLongitude;

  DiscoverMapDirections({required this.destinationLatitude,
    required this.destinationLongitude});

  Future<void> open() async {
    final String destination = '$destinationLatitude,$destinationLongitude';
    String url = "";
    if (Platform.isIOS) {
      url = 'http://maps.apple.com/?daddr=$destination&dirflg=d';
    } else {
      url = 'https://www.google.com/maps/dir/?api=1&destination='
        '$destination&travelmode=driving';
    }
    await launchUrl(Uri.parse(url));
  }
}