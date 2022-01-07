class OrderBookEntity {
  final String eventType;
  final int eventTime;
  final String symbol;
  final int firstUpdateID;
  final int finalUpdateID;
  final List<dynamic> bids;
  final List<dynamic> asks;

  OrderBookEntity(
      {required this.eventType,
      required this.eventTime,
      required this.symbol,
      required this.firstUpdateID,
      required this.finalUpdateID,
      required this.bids,
      required this.asks});

  factory OrderBookEntity.fromJson(Map<String, dynamic> json) {
    return OrderBookEntity(
        eventType: json['e'],
        eventTime: json['E'],
        symbol: json['s'],
        firstUpdateID: json['U'],
        finalUpdateID: json['u'],
        bids: json['b'],
        asks: json['a']);
  }
}
