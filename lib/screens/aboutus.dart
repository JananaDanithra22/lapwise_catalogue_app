import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: const Color(0xFF78B3CE), // Updated colors
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white, // Top color
              Color(0xFFC9E6F0), // Bottom color updated
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView( // Added scroll in case content exceeds screen
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20.0), // space between AppBar and logo
                Center(
                  child: Image.asset(
                    'assets/images/lapwiselogo.png',
                    height: 180.0,
                    width: 180.0,
                  ),
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Welcome to LapWise Catalogue App!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'LapWise Catalogue App is designed to simplify your laptop search experience in Sri Lanka. '
                  'We offer a comprehensive collection of the latest laptops with detailed specifications and trusted seller information. '
                  'While purchases are not made directly through our app, we connect you with verified sellers and help you make informed decisions with ease.\n\n'
                  'Our built-in comparison tool also allows you to evaluate multiple laptops side-by-side, helping you find the best device that matches your needs and budget.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, height: 1.5),
                ),
                const SizedBox(height: 40.0),
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15.0),
                const Text(
                  'Email: support@lapwise.com\n'
                  'Phone: +1 234 567 890\n'
                  'Address: 123 LapWise St, Tech City, 456789',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
