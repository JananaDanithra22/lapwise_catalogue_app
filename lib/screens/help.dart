import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 103, 58, 183),
      ),
      body: SingleChildScrollView( // 🛝 Added scroll view here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📸 Image Section
              Center(
                child: Image.asset(
                  'assets/images/Help.jpg',
                  height: 250,
                  width: 250,
                ),
              ),
              const SizedBox(height: 16),

              // Title Section
              const Text(
                'Need Assistance?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'If you have any issues or questions about using the LapWise Catalogue App, '
                'we are here to help! Please feel free to reach out to us anytime.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),

              // Contact Details Section
              const Text(
                'Contact Details:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Email: support@lapwise.com\nPhone: +94 71 925 5547\nWorking Hours: Mon - Fri, 9AM - 6PM',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Frequently Asked Questions Section (FAQ)
              const Text(
                'Frequently Asked Questions (FAQ):',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // FAQ item 1
              ExpansionTile(
                title: const Text(
                  'How do I search for laptops?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'To search for laptops, simply type your desired laptop model or category in the search bar at the top of the home page.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              // FAQ item 2
              ExpansionTile(
                title: const Text(
                  'Can I compare laptops?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Yes, you can compare multiple laptops by selecting the "Compare" button next to the laptops you want to compare.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              // FAQ item 3
              ExpansionTile(
                title: const Text(
                  'How do I contact customer support?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'You can reach customer support via email at support@lapwise.com or by calling +1 234 567 890 during working hours (Mon - Fri, 9AM - 6PM).',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32), // ⬅️ Added spacing at bottom

              // Contact Support Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Action on button press (e.g., launch an email or contact form)
                  },
                  icon: const Icon(Icons.mail),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 134, 218, 223),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
