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

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class InitialLaptopLoader extends StatelessWidget {
//   const InitialLaptopLoader({super.key});

//   Future<String?> _getFirstLaptopId() async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection('laptops').limit(1).get();

//     if (snapshot.docs.isNotEmpty) {
//       return snapshot.docs.first.id;
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String?>(
//       future: _getFirstLaptopId(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data == null) {
//           return const Scaffold(body: Center(child: Text('No laptops found.')));
//         }

//         return LaptopDetailsPage(laptopId: snapshot.data!);
//       },
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'LapWise Catalogue',
//       debugShowCheckedModeBanner: false,
//       home: const LoginPage(), // 👈 start from login
//       routes: {
//         '/splash': (context) => const SplashScreen(),
//         '/login': (context) => const LoginPage(),
//         '/home': (context) => const HomePage(),
//         '/help': (context) => const HelpPage(),
//         '/about': (context) => const AboutUsPage(),
//         '/lap': (context) => const InitialLaptopLoader(),
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';

void main() => runApp(ProductComparisonApp());

class ProductComparisonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductComparisonScreen(),
    );
  }
}

class ProductComparisonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PRODUCT COMPARISON"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ProductCard(),
                ),
                SizedBox(width: 10),
                AddProductButton(),
                SizedBox(width: 10),
                AddProductButton(),
              ],
            ),
            SizedBox(height: 30),
            InfoRow(label: "Type", value: "Laptop Stand"),
            InfoRow(label: "Model", value: "IMPO - LAPTOP-STAND"),
            InfoRow(label: "Adjustments", value: "6 Nots Lift"),
            InfoRow(label: "Foldable", value: "YES"),
            InfoRow(label: "Number Of Devices Can Be Attached", value: "01 Laptop"),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Image.network(
              'https://example.com/laptop_stand_image.jpg', // Replace with actual image URL
              height: 100,
            ),
            SizedBox(height: 10),
            Text(
              "IMPO Laptop Stand - Creative Folding Storage Bracket",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("IMPO-LAPTOP-STAND"),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => Icon(Icons.star, color: Colors.orange, size: 16)),
            ),
            SizedBox(height: 5),
            Text("2,999", style: TextStyle(fontSize: 18, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class AddProductButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
        child: Text("Add More Products"),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
