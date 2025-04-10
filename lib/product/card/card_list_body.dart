import 'dart:convert';

import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/card/card_element.dart';
import 'package:dulno/product/card/card_page.dart';
import 'package:dulno/product/profile/profile_page.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CardListBody extends ProductPageBody {
  final GlobalKey<_CardListBodyContentState> _key =
      GlobalKey<_CardListBodyContentState>();

  CardListBody({super.key})
      : super(name: "product.card.list.label", icon: Icon(Icons.wallet));

  @override
  Widget content(BuildContext context) {
    return CardListBodyContent(key: _key);
  }

  void reload() {
    _key.currentState?.reload();
  }
}

class CardListBodyContent extends StatefulWidget {
  const CardListBodyContent({super.key});

  @override
  State<CardListBodyContent> createState() => _CardListBodyContentState();
}

class _CardListBodyContentState extends State<CardListBodyContent> {
  bool _loaded = false;
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _cards = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  void reload() async {
    const storage = FlutterSecureStorage();
    final cardCache = await storage.read(key: "card_cache");
    _cards = cardCache == null ? [] : jsonDecode(cardCache);
    setState(() {});
  }

  Future<void> refresh() async {
    await fetchCards(false);
    setState(() {
      _controller.text = "";
    });
  }

  Future<void> fetchCards(reloadAfterwards) async {
    var response = await Request.get(url: "/user/cards/").send();
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    _cards = responseBody["cards"];
    const storage = FlutterSecureStorage();
    await storage.write(key: "card_cache", value: jsonEncode(_cards));
    if (reloadAfterwards) {
      setState(() {});
    }
  }

  Future<Widget> createCardElements(value) async {
    if (!_loaded) {
      const storage = FlutterSecureStorage();
      final cardCache = await storage.read(key: "card_cache");
      _cards = cardCache == null ? [] : jsonDecode(cardCache);
      fetchCards(true);
      setState(() {
        _loaded = true;
      });
    }
    if (_cards.isEmpty) {
      const storage = FlutterSecureStorage();
      var storedEmail = await storage.read(key: "email");
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 20, bottom: 75),
        child: Stack(
          children: [
            storedEmail == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child:
                            LocaleText("product.card.list.login.description"),
                      ),
                      Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            minimumSize: Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                            );
                          },
                          child: LocaleText(
                            "product.card.list.login.call",
                            style: TextStyle(
                              color: Colors.indigo,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            CardListScanArrow(),
          ],
        ),
      );
    }
    _cards.sort(
        (a, b) => (b["lastUpdate"] as num).compareTo(a["lastUpdate"] as num));
    var elements = <Widget>[];
    for (var card in _cards) {
      if (value.toString().isEmpty ||
          card["partnerName"]
              .toString()
              .toLowerCase()
              .contains(value.toString().toLowerCase())) {
        elements.add(GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CardPage(content: card)));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ProductCardElement(isLoading: false, content: card),
          ),
        ));
      }
    }
    if (elements.isEmpty) {
      elements.add(
        LocaleText(
          "product.card.list.empty",
          textAlign: TextAlign.center,
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 75),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [createSearchBar(), ...elements]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, child) {
          return FutureBuilder<Widget>(
            future: createCardElements(value.text),
            builder: (context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_loaded) {
                return Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 75),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Skeletonizer(
                          child: Skeleton.leaf(
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child:
                              ProductCardElement(isLoading: true, content: {}),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child:
                              ProductCardElement(isLoading: true, content: {}),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return snapshot.data ?? SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget createSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, child) {
          return TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.grey[500]),
              hintText: Locales.string(context, "product.card.list.search"),
              prefixIcon: Icon(Icons.search),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          );
        },
      ),
    );
  }
}

class CardListScanArrow extends StatefulWidget {
  const CardListScanArrow({super.key});

  @override
  State<CardListScanArrow> createState() => _CardListScanArrowState();
}

class _CardListScanArrowState extends State<CardListScanArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, _animation.value - 10),
                child: Transform(
                  transform: Matrix4.diagonal3Values(1, 1.25, 1),
                  alignment: Alignment.center,
                  child:
                      Icon(Icons.arrow_downward, size: 30, color: Colors.black),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -75),
                child: LocaleText("product.card.list.stamp.description"),
              ),
            ],
          );
        },
      ),
    );
  }
}
