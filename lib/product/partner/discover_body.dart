import 'dart:convert';

import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/partner/discover_map.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DiscoverBody extends ProductPageBody {
  DiscoverBody({super.key})
      : super(name: "product.discover.label", icon: Icon(Icons.location_pin));

  final MapController controller = MapController();

  @override
  Widget content(BuildContext context) {
    return FutureBuilder<List<LatLng>>(
      future: findPartnerLocations(),
      builder: (context, AsyncSnapshot<List<LatLng>> snapshot) {
        return OSMMap(
          data: snapshot.data ?? [],
          mapController: controller,
          latitude: 51.1657,
          longitude: 10.4515,
          radius: 0,
        );
      },
    );
  }

  Future<List<LatLng>> findPartnerLocations() async {
    var response = await Request.get(url: "/user/partners/").send();
    var responseBody = jsonDecode(response.body);
    var locations = <LatLng>[];
    for (var partner in responseBody["partners"]) {
      for (var location in partner["locations"]) {
        locations.add(LatLng(location["latitude"], location["longitude"]));
      }
    }
    return locations;
  }
}
