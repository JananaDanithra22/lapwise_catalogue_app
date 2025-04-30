// lib/screens/terms.dart
import 'package:flutter/material.dart';

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF78B3CE),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Terms & Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Here you can describe the terms and privacy policies of LapWise.lk.\n\n'
            'You may want to include:\n'
            '- User data handling\n'
            '- Security policies\n'
            '- User responsibilities\n'
            '- Contact info for policy inquiries\n\n'
            'This is a placeholder text.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
