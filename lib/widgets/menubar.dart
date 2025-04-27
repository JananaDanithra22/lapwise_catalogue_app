import 'package:flutter/material.dart';

class CustomMenuBar extends StatelessWidget { // Renamed here
  const CustomMenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('LapWise User'),
            accountEmail: const Text('user@lapwise.com'),
            currentAccountPicture: IconButton(
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/lapwiselogo.png'), // Your logo or profile pic
              ),
              iconSize: 60.0,  // Adjust the size of the profile photo
              onPressed: () {
                // Add the action for the profile picture button, such as navigating to the profile page
                Navigator.pushNamed(context, '/profile'); // Assuming '/profile' route exists
              },
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF78B3CE),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings), // Settings icon
            title: const Text('Settings'),  // Title for Settings
            onTap: () {
              Navigator.pushNamed(context, '/settings'); // Assuming '/settings' route exists
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }
}
