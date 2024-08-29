// main.dart

import 'package:drama/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Series Player',
      theme: ThemeData(
        brightness: Brightness.dark, // Set dark theme
        primarySwatch: Colors.red, // Primary color for your theme
        scaffoldBackgroundColor: Colors.black, // Background color for the scaffold
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withOpacity(0.5), // Transparent black for glass effect
          selectedItemColor: Colors.red, // Color for selected item
          unselectedItemColor: Colors.white, // Color for unselected items
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Ensure text is white
        ),
      ),
      home: SplashScreen(),
    );
  }
}
