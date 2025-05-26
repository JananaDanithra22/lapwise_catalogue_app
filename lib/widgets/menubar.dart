import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapwise_catalogue_app/screens/themeprovider.dart';

class CustomMenuBar extends StatefulWidget {
  const CustomMenuBar({Key? key}) : super(key: key);

  @override
  State<CustomMenuBar> createState() => _CustomMenuBarState();
}

class _CustomMenuBarState extends State<CustomMenuBar> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();
    setState(() {
      _isAdmin = doc.exists;
    });
  }

  Future<void> _generateKeywords() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('laptops').get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final name = data['name'] ?? '';
        final brand = data['brand'] ?? '';
        final processor = data['processor'] ?? '';
        final gpu = data['gpu'] ?? '';
        final price = data['price']?.toString() ?? '';

        final keywords = <String>{
          ...name.toString().toLowerCase().split(' '),
          brand.toString().toLowerCase(),
          processor.toString().toLowerCase(),
          gpu.toString().toLowerCase(),
          price,
        };

        await FirebaseFirestore.instance
            .collection('laptops')
            .doc(doc.id)
            .update({'keywords': keywords.toList()});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Keywords generated for all laptops')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to generate keywords: $e')),
      );
    }
  }

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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF96E2A),
                  foregroundColor: Colors.white, // This sets the text color
                ),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                // ✅ DARK MODE TOGGLE STARTS HERE
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Dark Mode'),
                  trailing: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                        child: Switch(
                          key: ValueKey(themeProvider.isDarkMode),
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: const Color(0xFFF96E2A),
                        ),
                      );
                    },
                  ),
                ),
                if (_isAdmin)
                  ListTile(
                    leading: const Icon(Icons.build_circle),
                    title: const Text('Generate Laptop Keywords'),
                    onTap: _generateKeywords,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              bottom: 40,
            ), // Moves whole row right
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFF96E2A)),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFF96E2A),
                  fontWeight: FontWeight.bold, // Makes it bold
                ),
              ),
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }
}
