import 'dart:async';
import 'dart:collection';

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
  // Binance api
  final _binanceApi = Binance();
  StreamSubscription<BookDepth>? _bookSubscription;
  bool _isFirstEvent = true;

  // Work with book
  final _bookBuffer = Queue<DiffBookDepth>();
  BookDepth? _book;

  // State
  final String _symbol = "BTCUSDT";

  @override
  void initState() {
    // 1. Open a stream to wss://stream.binance.com:9443/ws/bnbbtc@depth.
    _bookSubscription = _binanceApi.diffBookDepth(_symbol).listen((diffBook) {
      // 2. Buffer the events you receive from the stream.
      _bookBuffer.add(diffBook);

      if (_book != null) {
        setState(() {
          while (_bookBuffer.isNotEmpty == true) {
            DiffBookDepth diffBook = _bookBuffer.removeFirst();

            // 4. Drop any event where u is <= lastUpdateId in the snapshot.
            if (diffBook.lastUpdateId <= _book!.lastUpdateId) {
              return;
            }

            // 5. The first processed event should have U <= lastUpdateId+1 AND u >= lastUpdateId+1.
            if (_isFirstEvent == true &&
                diffBook.firstUpdateId <= _book!.lastUpdateId + 1 &&
                diffBook.lastUpdateId >= _book!.lastUpdateId + 1) {
              _mergeBook(diffBook);
              _isFirstEvent = false;
              return;
            }

            // 6. While listening to the stream, each new event's U should be equal to the previous event's u+1.
            if (diffBook.firstUpdateId != _book!.lastUpdateId + 1) {
              return;
            }

            _mergeBook(diffBook);
          }
        });
      }
    });

    // 3. Get a depth snapshot from https://api.binance.com/api/v3/depth?symbol=BNBBTC&limit=1000
    _binanceApi.depth(_symbol, 20).then((book) {
      _book = book;
    });

    super.initState();
  }

  _mergeBook(DiffBookDepth diffBook) {
    // 7. The data in each event is the absolute quantity for a price level.
    // (просто заменяемое значение - абсолютное, не передают какую либо разницу между двумя величинами)
    // 8. If the quantity is 0, remove the price level.
    // 9. Receiving an event that removes a price level that is not in your local order book can happen and is normal.

    // Update asks
    for (var a in diffBook.asks) {
      var aIdx = _book!.asks.indexWhere((_a) => _a.price == a.price);
      if (aIdx == -1) {
        _book!.asks.add(a);
      } else if (_book!.asks[aIdx].qty == 0) {
        _book!.asks.removeAt(aIdx);
      } else {
        _book!.asks[aIdx] = a;
      }
    }

    // Update bids
    for (var b in diffBook.bids) {
      var bIdx = _book!.bids.indexWhere((_b) => _b.price == b.price);
      if (bIdx == -1) {
        _book!.bids.add(b);
      } else if (_book!.bids[bIdx].qty == 0) {
        _book!.bids.removeAt(bIdx);
      } else {
        _book!.bids[bIdx] = b;
      }
    }

    // Sort all price levels
    _book!.asks.sort((a, b) => b.price.compareTo(a.price));
    _book!.bids.sort((a, b) => b.price.compareTo(a.price));

    // Update lastUpdateId
    _book!.lastUpdateId = diffBook.lastUpdateId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ListView(
      children: _book != null
          ? [
              ..._book!.asks.map((p) => PriceLevelWidget(
                    price: p.price,
                    color: Colors.red,
                    quantity: p.qty,
                    indicator: 0,
                  )),
              ..._book!.bids.map((p) => PriceLevelWidget(
                    price: p.price,
                    color: Colors.green,
                    quantity: p.qty,
                    indicator: 0,
                  ))
            ]
          : [],
    )));
  }

  @override
  void dispose() {
    _bookSubscription!.cancel();
    super.dispose();
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
