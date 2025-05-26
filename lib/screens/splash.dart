import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay 2 seconds and navigate
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login'); // Change to your route
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // or your theme color
      body: Center(
        child: Image(
          image: AssetImage('assets/images/Logo.png'),
          width: 280, // Make logo a bit larger
          height: 280,
        ),
      ),
    );
  }
}
