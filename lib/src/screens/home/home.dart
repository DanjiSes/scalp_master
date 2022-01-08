import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PriceLevel {
  final double price;
  final double quantity;

  PriceLevel(this.price, this.quantity);
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
    Uri.parse('wss://stream.binance.com:9443/ws/btsusdt@depth@1000ms'),
  );

  Map<double, PriceLevel> _bids = {};
  Map<double, PriceLevel> _asks = {};

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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_bids.toString()),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_asks.toString()),
          )
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

// StreamBuilder(
//   stream: _channel.stream,
//   builder: (context, AsyncSnapshot<dynamic> snapshot) {
//     if (!snapshot.hasData) {
//       return const Center(
//         child: Text('Loading...'),
//       );
//     }

//     var data = jsonDecode(snapshot.data);

//     var bids = normalizeOrderBook(data['b'] as List<dynamic>);
//     var asks = normalizeOrderBook(data['a'] as List<dynamic>);

//     return OrderBookWidget(
//       asks: asks,
//       bids: bids,
//     );
//   })