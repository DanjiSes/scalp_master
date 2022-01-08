import 'package:flutter/material.dart';
import 'package:scalp_master/order_book.dart';

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
