import 'package:flutter/material.dart';
import 'package:scalp_master/src/entities/order_book.dart';
import 'package:scalp_master/src/widgets/order_book/price_row_widget.dart';

class OrderBookWidget extends StatefulWidget {
  const OrderBookWidget({
    Key? key,
    required this.orderBookData,
  }) : super(key: key);

  final OrderBookEntity orderBookData;

  @override
  _OrderBookWidgetState createState() => _OrderBookWidgetState();
}

class _OrderBookWidgetState extends State<OrderBookWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...widget.orderBookData.asks.reversed.map((e) {
          return PriceRowWidget(
            price: double.parse(e[0]).toString(),
            color: Colors.green,
            volume: e[1].toString(),
          );
        }),
        ...widget.orderBookData.bids.map((e) {
          return PriceRowWidget(
            price: double.parse(e[0]).toString(),
            color: Colors.red,
            volume: e[1].toString(),
          );
        }),
      ],
    );
  }
}
