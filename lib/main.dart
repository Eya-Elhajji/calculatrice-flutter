// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/calculator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Force l'orientation portrait, comme vu sur la capture d'écran
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculatrice',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}