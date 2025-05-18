import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapwise_catalogue_app/screens/home.dart';
import 'package:lapwise_catalogue_app/screens/help.dart';
import 'package:lapwise_catalogue_app/screens/aboutus.dart';
import 'package:lapwise_catalogue_app/screens/splash.dart';
import 'package:lapwise_catalogue_app/screens/login.dart';
import 'package:lapwise_catalogue_app/screens/setting.dart';
import 'package:lapwise_catalogue_app/screens/profile.dart';
import 'package:lapwise_catalogue_app/screens/privacy_settings.dart';
import 'package:lapwise_catalogue_app/screens/lapdetails.dart';
import 'package:lapwise_catalogue_app/screens/compareScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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

        return const Scaffold(
          body: Center(
            child: Text('LaptopDetailsPage not available in this branch'),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LapWise Catalogue',
      debugShowCheckedModeBanner: false,
      home:
          ProductComparisonScreen(), // 👈 no 'const' because your class isn't marked const
      // 👈 start from login
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/help': (context) => const HelpPage(),
        '/about': (context) => const AboutUsPage(),
        '/lap': (context) => const InitialLaptopLoader(),
        '/compare': (context) => ProductComparisonScreen(),
      },
    );
  }
}
<<<<<<< HEAD

=======
>>>>>>> ceae9f5025aed6f386e8d7b36a4402a3c2d84ef4
