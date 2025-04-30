import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:lapwise_catalogue_app/screens/home.dart';
import 'package:lapwise_catalogue_app/screens/help.dart';
import 'package:lapwise_catalogue_app/screens/aboutus.dart';
import 'package:lapwise_catalogue_app/screens/splash.dart';
import 'package:lapwise_catalogue_app/screens/login.dart';
import 'package:lapwise_catalogue_app/screens/setting.dart';  // Import SettingsPage
import 'package:lapwise_catalogue_app/screens/profile.dart';    // Import ProfilePage
import 'package:lapwise_catalogue_app/screens/privacy_settings.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LapWise Catalogue',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home', // Start from HomePage now
      routes: {
        '/splash': (context) => const SplashScreen(), // Optional if you need splash later
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/help': (context) => const HelpPage(),
        '/about': (context) => const AboutUsPage(),
        '/profile': (context) => const ProfilePage(), // Profile Page route
        '/settings': (context) => const SettingsPage(), // Add Settings route
      },
    );
  }
}
