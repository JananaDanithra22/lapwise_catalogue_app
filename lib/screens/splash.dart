import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Delay 2 seconds and navigate
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login'); // Change to your route
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // or your theme color
      body: Center(
        child: Image(
          image: AssetImage('assets/images/lapwiselogo.png'),
          width: 280, // Make logo a bit larger
          height: 280,
        ),
      ),
    );
  }
}
