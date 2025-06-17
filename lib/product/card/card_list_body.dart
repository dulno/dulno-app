import 'dart:convert';

import 'package:dulno/localization/locale_text.dart';
import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/card/card_element.dart';
import 'package:dulno/product/card/card_list_empty.dart';
import 'package:dulno/product/card/card_page.dart';
import 'package:dulno/product/card/card_search_bar.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CardListBody extends ProductPageBody {
  final GlobalKey<_CardListBodyContentState> _key =
      GlobalKey<_CardListBodyContentState>();

  CardListBody({super.key})
      : super(
            name: "product.card.list.label",
            unselectedIcon: CupertinoIcons.creditcard,
            selectedIcon: CupertinoIcons.creditcard_fill);

  @override
  Widget content(BuildContext context) {
    return CardListBodyContent(key: _key);
  }

  void reload() {
    _key.currentState?.reload();
  }

  void refresh(context) {
    _key.currentState?.refresh(context);
  }
}

class CardListBodyContent extends StatefulWidget {
  const CardListBodyContent({super.key});

  @override
  State<CardListBodyContent> createState() => _CardListBodyContentState();
}

class _CardListBodyContentState extends State<CardListBodyContent> {
  bool _loaded = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _cards = [];
  List<dynamic> _previousCards = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void reload() async {
    const storage = FlutterSecureStorage();
    final cardCache = await storage.read(key: "cards");
    _cards = cardCache == null ? [] : jsonDecode(cardCache);
    if (mounted) {
      setState(() {
        scrollToTop();
      });
    }
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> refresh(context) async {
    await fetchCards(context, false);
    if (mounted) {
      setState(() {
        _searchController.text = "";
      });
    }
  }

  Future<void> fetchCards(context, reloadAfterwards) async {
    const storage = FlutterSecureStorage();
    var body = <String, Object>{};
    final cardCache = await storage.read(key: "cards");
    var cards = (cardCache == null ? [] : jsonDecode(cardCache))
        .map((card) => card["itemId"])
        .toList();
    body["cards"] = cards;
    var response =
        await Request.post(url: "/user/cards/", body: body).send(context);
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody.isEmpty) {
      return;
    }
    _cards = responseBody["items"];
    await storage.write(key: "cards", value: jsonEncode(_cards));
    if (reloadAfterwards && mounted) {
      setState(() {});
    }
  }

  Future<Widget> createCardElements(context, value) async {
    if (!_loaded) {
      const storage = FlutterSecureStorage();
      final cardCache = await storage.read(key: "cards");
      _cards = cardCache == null ? [] : jsonDecode(cardCache);
      _previousCards = _cards;
      fetchCards(context, true);
      setState(() {
        _loaded = true;
      });
    }
    if (_cards.isEmpty) {
      return CardListEmptyContent(signInCallback: () {
        refresh(context);
      });
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
            child: CardElement(
              key: ValueKey(card["itemId"].toString()),
              isLoading: false,
              content: card,
              animateLastStamp: detectCardStampUpdate(card),
              animateCard: detectNewCard(card),
            ),
          ),
        ));
      }
    }
    _previousCards = _cards;
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
        controller: _scrollController,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 75),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: 360,
            child: Column(
              children: [
                CardSearchBar(
                  controller: _searchController,
                ),
                ...elements
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool detectCardStampUpdate(card) {
    var previousCardOptional =
        _previousCards.where((entry) => entry["itemId"] == card["itemId"]);
    if (previousCardOptional.isEmpty) {
      return card["cardType"] == "COLLECTION";
    }
    var previousCard = previousCardOptional.first;
    var type = previousCard["cardType"];
    if (type == "COLLECTION" || type == "VALUE") {
      return previousCard["stamps"] != card["stamps"];
    }
    return false;
  }

  bool detectNewCard(card) {
    var previousCardOptional =
        _previousCards.where((entry) => entry["itemId"] == card["itemId"]);
    if (previousCardOptional.isNotEmpty) {
      return false;
    }
    var type = card["cardType"];
    return type == "VALUE" || type == "MEMBER";
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => refresh(context),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return FutureBuilder<Widget>(
            future: createCardElements(context, value.text),
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
                          child: CardElement(
                            isLoading: true,
                            content: {},
                            animateLastStamp: false,
                            animateCard: false,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: CardElement(
                            isLoading: true,
                            content: {},
                            animateLastStamp: false,
                            animateCard: false,
                          ),
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
}
