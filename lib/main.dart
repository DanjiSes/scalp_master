import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Scalping Helper by Savchenko.dev',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: const MyHomePage());
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
  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://stream.binance.com:9443/ws/btcusdt@depth@1000ms'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: _channel.stream,
            builder: (context, snapshot) {
              // return Text(snapshot.hasData ? "${snapshot.data}" : '');

              if (snapshot.hasData) {
                var orderBook =
                    OrderBook.fromJson(jsonDecode("${snapshot.data}"));
                return ListView(
                  children: [
                    ...orderBook.bids.map((e) {
                      return PriceItemWidget(
                        price: double.parse(e[0]),
                        color: Colors.green,
                        volume: e[1].toString(),
                      );
                    }),
                    ...orderBook.asks.map((e) {
                      return PriceItemWidget(
                        price: double.parse(e[0]),
                        color: Colors.red,
                        volume: e[1].toString(),
                      );
                    }),
                  ],
                );
              }

              return ListView(
                children: const [],
              );
            }));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}

class PriceItemWidget extends StatefulWidget {
  const PriceItemWidget(
      {Key? key,
      required this.volume,
      required this.price,
      required this.color})
      : super(key: key);

  final String volume;
  final double price;
  final Color color;

  @override
  _PriceItemWidgetState createState() => _PriceItemWidgetState();
}

class _PriceItemWidgetState extends State<PriceItemWidget> {
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
              color: bgColor,
              padding: const EdgeInsets.all(4),
              child: Text(
                widget.volume,
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

class OrderBook {
  final String eventType;
  final int eventTime;
  final String symbol;
  final int firstUpdateID;
  final int finalUpdateID;
  final List<dynamic> bids;
  final List<dynamic> asks;

  OrderBook(
      {required this.eventType,
      required this.eventTime,
      required this.symbol,
      required this.firstUpdateID,
      required this.finalUpdateID,
      required this.bids,
      required this.asks});

  factory OrderBook.fromJson(Map<String, dynamic> json) {
    return OrderBook(
        eventType: json['e'],
        eventTime: json['E'],
        symbol: json['s'],
        firstUpdateID: json['U'],
        finalUpdateID: json['u'],
        bids: json['b'],
        asks: json['a']);
  }
}
