// lib/screens/profile.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController(text: 'LapWise User');
  final TextEditingController _emailController = TextEditingController(text: 'user@lapwise.com');
  final TextEditingController _phoneController = TextEditingController(text: '+94 712 345 678');
  final TextEditingController _addressController = TextEditingController(text: 'Colombo, Sri Lanka');

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (!_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF78B3CE),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEdit,
            tooltip: _isEditing ? 'Save' : 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/lapwiselogo.png'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 8),

            TextFormField(
              initialValue: 'March 2024',
              decoration: const InputDecoration(labelText: 'Member Since'),
              enabled: false,
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _toggleEdit,
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              label: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF96E2A),
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
