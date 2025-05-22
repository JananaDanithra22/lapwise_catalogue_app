import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'home.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LaptopDetailsPage extends StatefulWidget {
  final String laptopId;
  const LaptopDetailsPage({super.key, required this.laptopId});

  @override
  State<LaptopDetailsPage> createState() => _LaptopDetailsPageState();
}

class _LaptopDetailsPageState extends State<LaptopDetailsPage> {
  bool showSellersDetails = false;
  Map<String, dynamic>? laptopData;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Uint8List> decodedImages = [];
  bool _isFavorited = false;

 @override
  void initState() {
    super.initState();
    fetchLaptopData();
    _checkIfFavorite();
  }

   Future<void> fetchLaptopData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('laptops')
            .doc(widget.laptopId)
            .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final imageBase64List = List<String>.from(data['imageBase64'] ?? []);
        decodedImages =
            imageBase64List.map((base64Image) {
              final cleaned =
                  base64Image.contains(',')
                      ? base64Image.split(',')[1]
                      : base64Image;
              return base64Decode(cleaned);
            }).toList();

        setState(() {
          laptopData = data;
        });
      }
    } else {
      setState(() {
        laptopData = {};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Laptop not found in Firestore.")),
      );
    }
  }

  Future<void> _checkIfFavorite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      // Not signed in, set favorite to false
      if (mounted) {
        setState(() {
          _isFavorited = false;
        });
      }
      return;
    }

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .doc(widget.laptopId)
            .get();

    if (mounted) {
      setState(() {
        _isFavorited = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please sign in to use favorites"),
            duration: Duration(seconds: 2),
          ),
        );
        // TODONavigate to login page here if needed
      }
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.laptopId);

    String message;

    try {
      if (_isFavorited) {
        await ref.delete();
        message = "Removed from Favourites 💔";
      } else {
        await ref.set({'addedAt': FieldValue.serverTimestamp()});
        message = "Added to Favourites 💛";
      }

      if (mounted) {
        setState(() {
          _isFavorited = !_isFavorited;
        });

        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), duration: Duration(seconds: 2)),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }