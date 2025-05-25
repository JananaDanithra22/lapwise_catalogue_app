import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomMenuBar extends StatelessWidget {
  const CustomMenuBar({Key? key}) : super(key: key);

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'user@lapwise.com';
    final String initials = email.substring(0, 2).toUpperCase();
    final String uid = user?.uid ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        String displayName = email;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? '';
          if (name.isNotEmpty) displayName = name;
        }

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: UserAccountsDrawerHeader(
            accountName: Text(
              'Welcome! $displayName 👋',
              style: const TextStyle(
                fontSize: 18, // Still using bigger font size
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: const SizedBox.shrink(),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFF78B3CE)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          UserAccountsDrawerHeader(
            accountName: const Text('LapWise User'),
            accountEmail: const Text('user@lapwise.com'),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/user.jpg'),
                radius: 40,

              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFF78B3CE)),
          ),
          _buildUserHeader(context),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Favourites'),
                  onTap: () => Navigator.pushNamed(context, '/favourites'),
                ),
                ListTile(
                  leading: const Icon(Icons.compare),
                  title: const Text('Comparisons'),
                  onTap: () => Navigator.pushNamed(context, '/comparisons'),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () => Navigator.pushNamed(context, '/help'),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About Us'),
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
