import 'package:flutter/material.dart';
import '../widgets/menubar.dart'; // Import the renamed CustomMenuBar widget

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LapWise Home'),
        centerTitle: true,
        backgroundColor: const Color(0xFF78B3CE),
      ),
      drawer: const CustomMenuBar(), // Use the renamed CustomMenuBar here
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Welcome to LapWise Catalogue App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Explore latest laptops and find your perfect match!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
