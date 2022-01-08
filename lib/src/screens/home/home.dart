import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  Map<dynamic, dynamic> _book = {};

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
      child: Text(_book.toString()),
    ));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void bufferBook(dynamic book) {
    setState(() {
      _book = book;
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