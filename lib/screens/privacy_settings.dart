// lib/screens/settings.dart
import 'package:flutter/material.dart';
import 'privacy_settings.dart'; // <-- Add this import!

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
              onPressed: () {
                Navigator.of(ctx).pop();
                // Add your delete account logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deletion process started.')),
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
                // Profile Settings
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Change Profile Picture'),
                  onTap: () {
                    print('Change Profile Picture tapped');
                  },
                ),
                const Divider(),

                // Notification Settings
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notification Settings'),
                  onTap: () {
                    print('Notification Settings tapped');
                  },
                ),
                const Divider(),

                // Privacy Settings (UPDATED)
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

                // Delete Account
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Delete Account'),
                  onTap: () {
                    _showDeleteConfirmation(context);
                  },
                ),
                const Divider(),

                // App Version Display
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  subtitle: const Text('9.0.2025'),
                  onTap: () {}, // Optional, no action needed
                ),
                const Divider(),

                // Logout
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

          // Footer
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
