// lib/screens/profile.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  Timestamp? _createdAt;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? 'LapWise User';
          _emailController.text = data['email'] ?? user.email ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _createdAt = data['createdAt']; // 🔥 Add this line
        });
      }
    }
  }

  void _toggleEdit() async {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (!_isEditing) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
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
            Builder(
              builder: (context) {
                User? user = FirebaseAuth.instance.currentUser;
                String initials = 'LW'; // default initials

                if (user != null &&
                    user.email != null &&
                    user.email!.isNotEmpty) {
                  final emailPrefix = user.email!.split('@')[0];
                  initials = emailPrefix.substring(0, 2).toUpperCase();
                }

                return CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF78B3CE),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
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
              enabled: false,
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
              initialValue:
                  _createdAt != null
                      ? '${_createdAt!.toDate().day}/${_createdAt!.toDate().month}/${_createdAt!.toDate().year}'
                      : 'Loading...',
              decoration: const InputDecoration(labelText: 'Member Since'),
              enabled: false,
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _toggleEdit,
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: Colors.white,
              ),
              label: Text(
                _isEditing ? 'Save Changes' : 'Edit Profile',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF96E2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
