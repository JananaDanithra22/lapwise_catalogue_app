import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lapdetails.dart'; // to navigate to detail screen
import 'dart:convert'; // for Base64 image

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> favouriteLaptops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavouriteLaptops();
  }

  Future<void> fetchFavouriteLaptops() async {
    if (uid == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Get all favourites for this user from 'favourites' collection
      final favSnapshot =
          await FirebaseFirestore.instance
              .collection('favourites')
              .where('userId', isEqualTo: uid)
              .get();

      List<Map<String, dynamic>> laptops = [];

      for (var favDoc in favSnapshot.docs) {
        final laptopId = favDoc['laptopId'];
        final doc =
            await FirebaseFirestore.instance
                .collection('laptops')
                .doc(laptopId)
                .get();

        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            data['id'] = laptopId;
            laptops.add(data);
          }
        }
      }

      if (mounted) {
        setState(() {
          favouriteLaptops = laptops;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading favourites: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Extract the first base64 image string from the Firestore array and remove the data URI prefix.
  String? getFirstImageBase64(List<dynamic>? imageList) {
    if (imageList == null || imageList.isEmpty) return null;

    final rawBase64 = imageList[0];
    if (rawBase64 is String && rawBase64.contains(',')) {
      final parts = rawBase64.split(',');
      if (parts.length == 2) {
        return parts[1]; // pure base64 string after comma
      }
    }
    return null;
  }

  Widget _buildLaptopImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return const Icon(Icons.laptop);
    }

    try {
      final bytes = base64Decode(base64Image);
      return Image.memory(bytes, width: 60, height: 60, fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.laptop);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (favouriteLaptops.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Favourites"),
          centerTitle: true, // Center title here
          backgroundColor: const Color(0xFF78B3CE),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("No favourites yet 💔")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourites"),
        centerTitle: true, // Center title here as well
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Your Favourite Laptops are here 🧡",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: favouriteLaptops.length,
              itemBuilder: (context, index) {
                final laptop = favouriteLaptops[index];
                return ListTile(
                  leading: _buildLaptopImage(
                    getFirstImageBase64(
                      laptop['imageBase64'] as List<dynamic>?,
                    ),
                  ),
                  title: Text(laptop['name'] ?? 'Unnamed Laptop'),
                  subtitle: Text("LKR ${laptop['price'] ?? 'N/A'}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                LaptopDetailsPage(laptopId: laptop['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
