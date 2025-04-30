// lib/screens/privacy_settings.dart
import 'package:flutter/material.dart';

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
        children: const [
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Enable Two-Factor Authentication'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Change Password'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.visibility_off),
            title: Text('Manage Visibility'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Terms & Privacy Policy'),
          ),
        ],
      ),
    );
  }
}
