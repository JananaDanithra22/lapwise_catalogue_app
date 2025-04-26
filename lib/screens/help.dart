import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart'; // 👈 Import your HomePage here

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // 👇 Function to launch email
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@lapwise.lk',
      query: 'subject=Support Request&body=Hi LapWise Support Team,',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email app';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 103, 58, 183),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()), // 👈 Navigate to HomePage
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/Help.jpg',
                  height: 250,
                  width: 250,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Need Assistance?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'If you have any issues or questions about using the LapWise Catalogue App, '
                'we are here to help! Please feel free to reach out to us anytime.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              const Text(
                'Contact Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Email: support@lapwise.com\nPhone: +94 71 925 5547\nWorking Hours: Mon - Fri, 9AM - 6PM',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Text(
                'Frequently Asked Questions (FAQ):',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _launchEmail,
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
