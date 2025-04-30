// lib/screens/settings.dart
import 'package:flutter/material.dart';
import 'privacy_settings.dart'; // existing
import 'notification_settings.dart'; // for Notification Settings
import 'package:lapwise_catalogue_app/screens/login.dart'; // Import the login page

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop(); // Close the delete confirmation dialog
                
                // Optional: Add loading dialog or processing time for the delete process
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Simulating deletion process (you can add actual deletion logic here)
                await Future.delayed(const Duration(seconds: 2));

                // Close the loading dialog after the "deletion" is simulated
                Navigator.of(context).pop();

                // Navigate to LoginPage and clear navigation history after deletion
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notification Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
                    );
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Privacy Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacySettingsPage()),
                    );
                  },
                ),
                const Divider(),

                // "Delete Account" list tile updated to handle account deletion and redirection
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Delete Account'),
                  onTap: () {
                    _showDeleteConfirmation(context);
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  subtitle: const Text('9.0.2025'),
                  onTap: () {},
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Logout'),
                  onTap: () {
                    print('Logout tapped');
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/lapwiselogo.png',
                  height: 90,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Version 9.0.2025',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                const Text(
                  '© 2025 LapWise.lk All rights reserved',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
