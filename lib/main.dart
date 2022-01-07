import 'package:flutter/material.dart';

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
      home: Scaffold(
          body: Container(
        width: 250,
        child: ListView(
          children: const [
            PriceItemWidget(
              price: 45.432,
              color: Colors.green,
              volume: '4M',
            ),
            Divider(thickness: 1, height: 1),
            PriceItemWidget(
              price: 45.432,
              color: Colors.red,
              volume: '4M',
            ),
            Divider(thickness: 1, height: 1)
          ],
        ),
      )),
    );
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
    var bgColor = widget.color.withOpacity(_highlighted ? 0.6 : 0.5);

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
