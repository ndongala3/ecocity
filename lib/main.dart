import 'package:flutter/material.dart';
import 'screens/map_screen.dart'; // importe ton écran principal

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecocity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: MapScreen(), // ← ton écran principal ici
    );
  }
}