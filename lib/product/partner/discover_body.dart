import 'dart:convert';

import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/partner/discover_map.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';

class DiscoverBody extends ProductPageBody {
  DiscoverBody({super.key})
      : super(
            name: "product.discover.label",
            unselectedIcon: CupertinoIcons.map,
            selectedIcon: CupertinoIcons.map_fill);

  final MapController controller = MapController();

  @override
  Widget content(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: findPartners(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return OSMMap(
          partners: snapshot.data ?? [],
          mapController: controller,
          latitude: 51.1657,
          longitude: 10.4515,
          radius: 0,
        );
      },
    );
  }

  Future<dynamic> findPartners() async {
    var response = await Request.get(url: "/user/partners/").send();
    if (response == null || response.statusCode == 409) {
      return [];
    }
    var responseBody = jsonDecode(response.body);
    return responseBody["partners"];
  }
}
