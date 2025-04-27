// lib/screens/profile.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF78B3CE), // Profile screen header color
      ),
      body: Center(
        child: const Text('User Profile Information'),
      ),
    );
  }
}
