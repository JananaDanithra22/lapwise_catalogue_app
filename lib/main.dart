import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/button.dart';




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

// This loads a laptop (used by /lap route)
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

// Main app widget with auth check
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LapWise Catalogue',
      debugShowCheckedModeBanner: false,
      home:

      
      

      // LaptopDetailsPage(laptopId: '7tY2XDTbJojNWKrhscfM'), //start here check compare page


      // 👈 start from login

      home: const AuthGate(), // 👈 This widget decides login or home
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/help': (context) => const HelpPage(),
        '/about': (context) => const AboutUsPage(),
        '/lap': (context) => const InitialLaptopLoader(),
        // '/compare': (context) => ProductComparisonScreen(),
      },
    );
  }
}


// void main() {
//   runApp(const ProductPage());
// }

// class ProductPage extends StatelessWidget {
//   const ProductPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         showPerformanceOverlay: false, 
//       home: Scaffold(
//         appBar: AppBar(title: const Text('LapWise Catalogue')),
//         body: const Product(),
//       ),
//     );
//   }
// }

// class Product extends StatelessWidget {
//   const Product({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: DynamicButtonStyle.customButtonStyle(
//         buttonTitle: 'Compare Products',
//         textStyle: const TextStyle(color: Colors.white, fontSize: 16),
//         backgroundColor: Colors.blue,
//         borderColor: Colors.transparent,
//         onPressed: () {
//           // Your logic goes here
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Compare button clicked! 💙')),
//           );
//         },
//       ),
//     );
//   }
// }

        '/compare': (context) => const ProductComparisonScreen(
          selectedProductIds: [
            '7tY2XDTbJojNWKrhscfM',
            'BlOc9P1YmR8GkqodSfu4',
          ],
        ),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/privacy': (context) => const PrivacySettingsPage(),
      },
    );
  }
}

// This widget checks login status
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

        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
 
