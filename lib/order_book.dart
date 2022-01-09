import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scalp_master/packages/binance-dart/lib/binance.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _binance = Binance();
  StreamSubscription<BookDepth>? _depthSubscription;

  // State
  List<PriceLevel> _book = [];
  num? _price;
  final String _symbol = "BTCUSDT";
  final num _bigQuantity = 30;
  final num _step = 1;

  @override
  void initState() {
    _depthSubscription =
        _binance.bookDepth(_symbol, 20, 100).listen(handleOrderbookSnapshot);
    _binance.depth(_symbol, 20).then(handleOrderbookSnapshot);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ListView(
        children: _price != null
            ? [
                ...transformOrderBook(_book, _price!).map((p) {
                  return PriceLevelWidget(
                      price: p.price,
                      color: p.isEmpty
                          ? Colors.grey
                          : p.isAsk
                              ? Colors.red
                              : Colors.green,
                      quantity: p.quantity,
                      indicator: _bigQuantity > 0
                          ? p.quantity / _bigQuantity
                          : _bigQuantity);
                })
              ]
            : const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text("Loading...")),
                )
              ],
      ),
    ));
  }

  @override
  void dispose() {
    _depthSubscription!.cancel();
    super.dispose();
  }

  void handleOrderbookSnapshot(BookDepth snapshot) {
    var bids = snapshot.bids;
    var asks = snapshot.asks;

    var bidsList = bids.map((b) => PriceLevel.bid(b.price, b.qty));
    var asksList = asks.map((a) => PriceLevel.ask(a.price, a.qty));

    var sortedBidsList = asksList.map((e) => e.price).toList();
    sortedBidsList.sort();

    var book = [...asksList, ...bidsList];

    setState(() {
      _book = book;
      _price = _price ?? roundIn(sortedBidsList.first, _step);
    });
  }

  List<PriceLevel> transformOrderBook(List<PriceLevel> book, num price) {
    var steppedBookMap = <num, PriceLevel>{};

    var firstStep = roundIn(price + price * 0.05, _step);
    var lastSetp = roundIn(price - price * 0.05, _step);
    var levelsCount = (firstStep - lastSetp) / _step;

    var levelsIterator =
        Iterable.generate(levelsCount.toInt(), (i) => lastSetp + i * _step);

    for (var l in levelsIterator) {
      steppedBookMap[l] = PriceLevel.empty(l, 0);
    }

    for (var p in _book) {
      var steppedPrice = roundIn(p.price, _step);
      steppedBookMap[steppedPrice] =
          PriceLevel(steppedPrice, p.quantity, p.type);
    }

    var steppedBook = steppedBookMap.values.toList();
    steppedBook.sort((a, b) => b.price.compareTo(a.price));

    return steppedBook;
  }
}

class PriceLevelWidget extends StatefulWidget {
  const PriceLevelWidget(
      {Key? key,
      required this.quantity,
      required this.price,
      required this.color,
      required this.indicator})
      : super(key: key);

  final num quantity;
  final num price;
  final Color color;
  final num indicator;

  @override
  _PriceLevelWidgetState createState() => _PriceLevelWidgetState();
}

class _PriceLevelWidgetState extends State<PriceLevelWidget> {
  bool _highlighted = false;

  void _highlightOn(PointerEvent details) {
    setState(() {
      _highlighted = true;
    });
  }

  void _highlightOff(PointerEvent details) {
    setState(() {
      _highlighted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 12);
    var bgColor = widget.color.withOpacity(_highlighted ? 0.4 : 0.3);

    return MouseRegion(
      onEnter: _highlightOn,
      onExit: _highlightOff,
      child: GestureDetector(
          child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [
                  widget.indicator.toDouble(),
                  widget.indicator.toDouble()
                ],
                colors: [
                  Colors.yellow.withOpacity(0.5),
                  bgColor,
                ],
              )),
              // color: bgColor,
              padding: const EdgeInsets.all(4),
              child: Text(
                widget.quantity.toString(),
                style: textStyle,
              ),
            )),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
                child: Container(
              color: bgColor,
              padding: const EdgeInsets.all(4),
              child: Text(
                widget.price.toString(),
                style: textStyle,
              ),
            )),
          ],
        ),
      )),
    );
  }
}

class PriceLevel {
  final String type;
  num price;
  num quantity;

  PriceLevel(this.price, this.quantity, this.type);

  get isAsk {
    return type == "sell";
  }

  get isBid {
    return type == "buy";
  }

  get isEmpty {
    return type == "empty";
  }

  factory PriceLevel.ask(num price, num quantity) {
    return PriceLevel(price, quantity, "sell");
  }

  factory PriceLevel.bid(num price, num quantity) {
    return PriceLevel(price, quantity, "buy");
  }

  factory PriceLevel.empty(num price, num quantity) {
    return PriceLevel(price, quantity, "empty");
  }

  @override
  String toString() {
    return "{price: $price, quantity: $quantity}";
  }
}

num roundIn(num number, num step) {
  var fixedArr = step.toString().split('.').reversed;
  var fixed = fixedArr.length > 1 ? fixedArr.first.length : 0;
  var result = number - number % step;
  return num.parse(result.toStringAsFixed(fixed));
}
