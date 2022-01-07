import 'package:scalp_master/src/entities/order_book.dart';

normalizeOrderBook(OrderBookEntity orderBook) {
  const normalizeCount = 100;

  var bids = orderBook.bids;
  var asks = orderBook.asks;

  for (var i = 0; i < normalizeCount - bids.length; i++) {
    bids.add(['0', '0']);
  }

  for (var k = 0; k < normalizeCount - asks.length; k++) {
    asks.add(['0', '0']);
  }

  return OrderBookEntity(
      eventType: orderBook.eventType,
      eventTime: orderBook.eventTime,
      symbol: orderBook.symbol,
      firstUpdateID: orderBook.firstUpdateID,
      finalUpdateID: orderBook.finalUpdateID,
      bids: bids,
      asks: asks);
}
