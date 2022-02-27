import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stockapp/ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('stock_box');

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Stock App',
    home: HomeScreen(),
  ));
}
