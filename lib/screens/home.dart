import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);  // Keep this constructor (from dev branch)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),  // Keep this title (from dev branch)
      ),
      body: const Center(
        child: Text('Welcome to Home Page!', style: TextStyle(fontSize: 24)),  // Keep this text (from dev branch)
      ),
    );
  }
}
