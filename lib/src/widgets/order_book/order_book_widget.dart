import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scalp_master/src/entities/order_book.dart';
import 'package:scalp_master/src/widgets/order_book/price_level_widget.dart';

class OrderBookWidget extends StatefulWidget {
  const OrderBookWidget({
    Key? key,
    required this.bids,
    required this.asks,
  }) : super(key: key);

  final List<dynamic> bids;
  final List<dynamic> asks;

  @override
  _OrderBookWidgetState createState() => _OrderBookWidgetState();
}

class _OrderBookWidgetState extends State<OrderBookWidget> {
  @override
  Widget build(BuildContext context) {
    var maxValue = 0.0;

    widget.asks.forEach((e) => maxValue = max(double.parse(e[1]), maxValue));
    widget.bids.forEach((e) => maxValue = max(double.parse(e[1]), maxValue));

    maxValue = maxValue * 2;

    return ListView(
      children: [
        ...widget.asks.reversed.map((e) {
          return PriceLevelWidget(
            price: double.parse(e[0]).toString(),
            color: Colors.red,
            volume: e[1].toString(),
            indicator: maxValue > 0 ? double.parse(e[1]) / maxValue : maxValue,
          );
        }),
        ...widget.bids.map((e) {
          return PriceLevelWidget(
            price: double.parse(e[0]).toString(),
            color: Colors.green,
            volume: e[1].toString(),
            indicator: maxValue > 0 ? double.parse(e[1]) / maxValue : maxValue,
          );
        }),
      ],
    );
  }
}
