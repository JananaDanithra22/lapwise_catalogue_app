import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Add your logo image
            Center(
              child: Image.asset(
                'assets/images/lapwiselogo.png',  // Make sure to add your logo in assets folder
                height: 250.0,       // Adjust the height based on your logo
                width: 250.0,        // Adjust the width based on your logo
              ),
            ),
            const SizedBox(height: 20.0), // Space between logo and description

            // Add the description under the logo
            const Text(
              'Welcome to LapWise Catalogue App!\n\n'
              'This app helps you find the best laptops according to your needs. '
              'We are a team of passionate developers working to make tech shopping easier!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40.0), // Space before contact details

            // Contact details section
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
