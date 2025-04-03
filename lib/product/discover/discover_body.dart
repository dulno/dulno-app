import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/discover/discover_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DiscoverBody extends ProductPageBody {
  DiscoverBody({super.key})
      : super(name: "product.discover.label", icon: Icon(Icons.location_pin));

  @override
  Widget content(BuildContext context) {
    return OSMMap(data: [const LatLng(51.1657, 10.4515)], mapController: MapController(), latitude: 51.1657, longitude: 10.4515, radius: 0,);
  }
}
