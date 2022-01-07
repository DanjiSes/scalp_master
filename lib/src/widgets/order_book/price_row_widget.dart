import 'package:flutter/material.dart';

class PriceRowWidget extends StatefulWidget {
  const PriceRowWidget(
      {Key? key,
      required this.volume,
      required this.price,
      required this.color})
      : super(key: key);

  final String volume;
  final String price;
  final Color color;

  @override
  _PriceRowWidgetState createState() => _PriceRowWidgetState();
}

class _PriceRowWidgetState extends State<PriceRowWidget> {
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

    if (double.parse(widget.volume) == 0) {
      bgColor = widget.color.withOpacity(0);
    }

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
