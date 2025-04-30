// lib/screens/manage_visibility.dart
import 'package:flutter/material.dart';

class ManageVisibilityPage extends StatefulWidget {
  const ManageVisibilityPage({Key? key}) : super(key: key);

  @override
  _ManageVisibilityPageState createState() => _ManageVisibilityPageState();
}

class _ManageVisibilityPageState extends State<ManageVisibilityPage> {
  bool _isProfilePublic = true;
  bool _showLastSeen = true;
  bool _showActivityStatus = true;
  bool _showEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Visibility'),
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Public Profile'),
            subtitle: const Text('Allow others to view your profile'),
            value: _isProfilePublic,
            onChanged: (value) {
              setState(() {
                _isProfilePublic = value;
              });
            },
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Show Last Seen'),
            subtitle: const Text('Allow others to see when you were last active'),
            value: _showLastSeen,
            onChanged: (value) {
              setState(() {
                _showLastSeen = value;
              });
            },
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Show Activity Status'),
            subtitle: const Text('Display your current activity status'),
            value: _showActivityStatus,
            onChanged: (value) {
              setState(() {
                _showActivityStatus = value;
              });
            },
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Show Email/Phone'),
            subtitle: const Text('Make contact info visible to others'),
            value: _showEmail,
            onChanged: (value) {
              setState(() {
                _showEmail = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
