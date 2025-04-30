import 'package:flutter/material.dart';
import 'terms.dart';
import 'change_password.dart';
import 'manage_visibility.dart'; // Import new screen

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.visibility_off),
            title: const Text('Manage Visibility'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageVisibilityPage()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Terms & Privacy Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsPrivacyPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
