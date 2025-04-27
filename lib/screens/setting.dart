// lib/screens/settings.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF78B3CE),  // AppBar color to match the theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Settings
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Change Profile Picture'),
              onTap: () {
                // Navigate to Profile Change (You can implement this later)
                print('Change Profile Picture tapped');
              },
            ),
            const Divider(),

            // Notification Settings
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              onTap: () {
                // Navigate to Notification Settings (You can implement this later)
                print('Notification Settings tapped');
              },
            ),
            const Divider(),

            // Privacy Settings
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Privacy Settings'),
              onTap: () {
                // Navigate to Privacy Settings (You can implement this later)
                print('Privacy Settings tapped');
              },
            ),
            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                // Add logout functionality here
                print('Logout tapped');
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
