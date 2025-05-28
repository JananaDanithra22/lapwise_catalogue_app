import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:lapwise_catalogue_app/screens/themeprovider.dart'; // <-- ThemeProvider file

import 'package:lapwise_catalogue_app/screens/home.dart';
import 'package:lapwise_catalogue_app/screens/help.dart';
import 'package:lapwise_catalogue_app/screens/aboutus.dart';
import 'package:lapwise_catalogue_app/screens/splash.dart';
import 'package:lapwise_catalogue_app/screens/login.dart';
import 'package:lapwise_catalogue_app/screens/profile.dart';
import 'package:lapwise_catalogue_app/screens/favourites.dart';
import 'package:lapwise_catalogue_app/screens/comparisons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'LapWise Catalogue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Light theme data
      darkTheme: ThemeData.dark(), // Dark theme data
      themeMode:
          themeProvider.currentTheme, // Use current theme mode from provider
      home: const AuthGate(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/comparisons': (context) => const ComparisonsScreen(),
        '/help': (context) => const HelpPage(),
        '/about': (context) => const AboutUsPage(),
        '/lap': (context) => const InitialLaptopLoader(),
        '/profile': (context) => const ProfilePage(),
        '/favourites': (context) => FavouritesPage(),
      },
    );
  }
}

// Laptop loader (unchanged)
class InitialLaptopLoader extends StatelessWidget {
  const InitialLaptopLoader({super.key});

  Future<String?> _getFirstLaptopId() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('laptops').limit(1).get();
    if (snapshot.docs.isNotEmpty) return snapshot.docs.first.id;
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
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No laptops found.')));
        }
        return const Scaffold(
          body: Center(
            child: Text('LaptopDetailsPage not available in this branch'),
          ),
        );
      },
    );
  }
}

// Auth check (unchanged)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
