import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 🔙 Back button
          onPressed: () {
            Navigator.pop(context); // 📦 Go back to the previous page (Home)
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/lapwiselogo.png', // 🖼️ Your logo
              height: 30, // Small size logo for appbar
            ),
            const SizedBox(width: 8),
            const Text('About Us'),
          ],
        ),
        centerTitle: true, // 🛠️ Center the row (logo + text) in the appbar
      ),
      body: Padding(
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
    );
  }
}
