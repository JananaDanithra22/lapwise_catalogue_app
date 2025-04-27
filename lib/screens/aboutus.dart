import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.pushNamed(context, '/home'); // 👈 Go to HomePage
          },
        ),
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFC9E6F0),
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
                'LapWise Catalogue App is designed to simplify your laptop search experience in Sri Lanka. '
                'We offer a comprehensive collection of the latest laptops along with detailed specifications and trusted seller information. '
                'While purchases are not made directly through our app, we connect you with verified sellers and help you make informed decisions.',
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
