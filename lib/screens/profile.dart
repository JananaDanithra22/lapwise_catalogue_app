// lib/screens/profile.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/lapwiselogo.png'), // Your user profile image
            ),
            const SizedBox(height: 16),

            // User Name
            const Text(
              'LapWise User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // User Email
            const Text(
              'user@lapwise.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // Account Information Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF78B3CE)),
                title: const Text('Phone'),
                subtitle: const Text('+94 712 345 678'), // Example Sri Lankan number
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Color(0xFF78B3CE)),
                title: const Text('Address'),
                subtitle: const Text('Colombo, Sri Lanka'),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF78B3CE)),
                title: const Text('Member Since'),
                subtitle: const Text('March 2024'),
              ),
            ),

            const SizedBox(height: 30),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: () {
                // You can navigate to edit profile page or show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile Coming Soon!')),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9E6F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
