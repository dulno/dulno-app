import 'dart:convert';

import 'package:dulno/product/base/page_body.dart';
import 'package:dulno/product/card/card_element.dart';
import 'package:dulno/product/profile/profile.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class CardListBody extends ProductPageBody {
  final GlobalKey<_CardListBodyContentState> _key =
      GlobalKey<_CardListBodyContentState>();

  CardListBody({super.key})
      : super(name: "product.card.list.label", icon: Icon(Icons.wallet));

  @override
  Widget content(BuildContext context) {
    return CardListBodyContent(key: _key);
  }

  void refresh() {
    _key.currentState?.refresh();
  }
}

class CardListBodyContent extends StatefulWidget {
  const CardListBodyContent({super.key});

  @override
  State<CardListBodyContent> createState() => _CardListBodyContentState();
}

class _CardListBodyContentState extends State<CardListBodyContent> {
  late Future<Widget> _cardElementsFuture;

  @override
  void initState() {
    super.initState();
    _cardElementsFuture = createCardElements();
  }

  Future<void> refresh() async {
    setState(() {
      _cardElementsFuture = createCardElements();
    });
    await _cardElementsFuture;
  }

  Future<Widget> createCardElements() async {
    var response = await Request.get(url: "/user/cards/").send();
    var responseBody = jsonDecode(response.body);
    var cards = responseBody["cards"];
    if (cards.length == 0) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 20, bottom: 75),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: LocaleText("product.card.list.login.description"),
                ),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      // Remove default padding, background, etc.
                      padding: EdgeInsets.zero,
                      minimumSize: Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    child: LocaleText(
                      "product.card.list.login.call",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CardListScanArrow(),
          ],
        ),
      );
    }
    var elements = <Widget>[];
    for (var card in cards) {
      elements.add(
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: ProductCardElement(content: card),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast,
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 20, bottom: 100),
        child: Column(children: elements),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      displacement: 20,
      child: FutureBuilder<Widget>(
        future: _cardElementsFuture,
        builder: (context, AsyncSnapshot<Widget> snapshot) {
          return snapshot.data ?? Container();
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
