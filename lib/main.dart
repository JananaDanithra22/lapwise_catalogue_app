import 'package:flutter/material.dart';
import 'homescreen.dart';

void main() {
  runApp(const LaptopStoreApp());
}

class LaptopStoreApp extends StatelessWidget {
  const LaptopStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LapWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/latest': (context) => const LatestScreen(),
        '/trending': (context) => const TrendingScreen(),
      },
    );
  }
}
