import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
         backgroundColor: const Color(0xFF78B3CE), // Updated color
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white, // Top color
              Color.fromARGB(255, 179, 163, 206), // Bottom color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Image.asset(
                  'assets/images/lapwiselogo.png',
                  height: 250.0,
                  width: 250.0,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Welcome to LapWise Catalogue App!\n\n'
                'This app helps you find the best laptops according to your needs. '
                'We are a team of passionate developers working to make tech shopping easier!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40.0),
              const Text(
                'Contact Us:\n\n'
                'Email: support@lapwise.com\n'
                'Phone: +1 234 567 890\n'
                'Address: 123 LapWise St, Tech City, 456789',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
