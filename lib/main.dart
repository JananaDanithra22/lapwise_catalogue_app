import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lapwise_catalogue_app/screens/aboutus.dart';
import 'firebase_options.dart';

// Pages
import 'package:lapwise_catalogue_app/screens/help.dart'; // ✅ Only import HelpPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LapWise Catalogue',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const HelpPage(), // 👈 Directly load HelpPage
    );
  }
}
