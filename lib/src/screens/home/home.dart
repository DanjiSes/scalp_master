import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scalp_master/src/entities/order_book.dart';
import 'package:scalp_master/src/widgets/order_book/order_book_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://stream.binance.com:9443/ws/shibusdt@depth@1000ms'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: _channel.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }

              return OrderBookWidget(
                  orderBookData: OrderBookEntity.fromJson(
                      json.decode("${snapshot.data}")));
            }));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
