import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF78B3CE),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts via app notifications'),
            value: _pushNotifications,
            onChanged: (bool value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive updates and newsletters via email'),
            value: _emailNotifications,
            onChanged: (bool value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Get account alerts via SMS'),
            value: _smsNotifications,
            onChanged: (bool value) {
              setState(() {
                _smsNotifications = value;
              });
            },
          ),
          const Divider(),
          Padding(
  padding: const EdgeInsets.all(16.0),
  child: ElevatedButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved.')),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF96E2A),
    ),
    child: const Text(
      'Save Settings',
      style: TextStyle(color: Colors.white), // Font color changed to white
    ),
  ),
),

        ],
      ),
    );
  }
}
