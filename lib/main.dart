import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapwise_catalogue_app/screens/splash.dart';
import 'package:lapwise_catalogue_app/screens/login.dart';
import 'package:lapwise_catalogue_app/screens/home.dart';
import 'package:lapwise_catalogue_app/screens/help.dart';
import 'package:lapwise_catalogue_app/screens/aboutus.dart';
import 'package:lapwise_catalogue_app/screens/lapdetails.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LapWise Catalogue',
      debugShowCheckedModeBanner: false,

      home: const LoginPage(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(), // ✅ FIXED: Use HomeScreen
        '/help': (context) => const HelpPage(),
        '/about': (context) => const AboutUsPage(),
        '/lap': (context) => const InitialLaptopLoader(),
      },
    );
  }
}

class InitialLaptopLoader extends StatelessWidget {
  const InitialLaptopLoader({super.key});

  Future<String?> _getFirstLaptopId() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('laptops').limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getFirstLaptopId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text('No laptops found.')));
        }

        return LaptopDetailsPage(laptopId: snapshot.data!);
      },
    );
  }
}
