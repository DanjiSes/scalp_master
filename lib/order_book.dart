import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PriceLevel {
  final double price;
  final double quantity;

  PriceLevel(this.price, this.quantity);

  @override
  String toString() {
    return "{price: $price, quantity: $quantity}";
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('wss://stream.binance.com:9443/ws/bnbbtc@depth'),
  );

  final Map<double, PriceLevel> _bids = {};
  final Map<double, PriceLevel> _asks = {};

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((message) {
      bufferBook(jsonDecode(message));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ListView(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(_asks.toString()),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(_bids.toString()),
              )
            ],
          )
          // ..._asks.values.toList().reversed.map((priceLeve) {
          //   return PriceLevelWidget(
          //       price: priceLeve.price,
          //       color: Colors.red,
          //       quantity: priceLeve.quantity,
          //       indicator:
          //           0.2 // maxValue > 0 ? double.parse(e[1]) / maxValue : maxValue,
          //       );
          // }),
          // ..._bids.values.toList().map((priceLevel) {
          //   return PriceLevelWidget(
          //       price: priceLevel.price,
          //       color: Colors.green,
          //       quantity: priceLevel.quantity,
          //       indicator:
          //           0.2 // maxValue > 0 ? double.parse(e[1]) / maxValue : maxValue,
          //       );
          // }),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void bufferBook(dynamic book) {
    setState(() {
      var bidsList = book['b'] as List<dynamic>;
      var asksList = book['a'] as List<dynamic>;

      for (var b in bidsList) {
        var price = double.parse(b[0]);
        var quantity = double.parse(b[1]);
        _bids[price] = PriceLevel(price, quantity);
      }

      for (var a in asksList) {
        var price = double.parse(a[0]);
        var quantity = double.parse(a[1]);
        _asks[price] = PriceLevel(price, quantity);
      }
    });
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

  final double quantity;
  final double price;
  final Color color;
  final double indicator;

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

    // if (double.parse(widget.volume) == 0) {
    //   bgColor = widget.color.withOpacity(0);
    // }

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
                stops: [widget.indicator, widget.indicator],
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
