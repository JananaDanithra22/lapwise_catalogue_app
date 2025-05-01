import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapwise_catalogue_app/screens/lapdetails.dart';

class LaptopRecommendations extends StatefulWidget {
  final String category;
  final String currentLaptopId;

  const LaptopRecommendations({
    Key? key,
    required this.category,
    required this.currentLaptopId,
  }) : super(key: key);

  @override
  _LaptopRecommendationsState createState() => _LaptopRecommendationsState();
}

class _LaptopRecommendationsState extends State<LaptopRecommendations> {
  List<Map<String, dynamic>> recommendedLaptops = [];

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('laptops')
            .where('category', isEqualTo: widget.category)
            .get();

    final laptops =
        querySnapshot.docs
            .where((doc) => doc.id != widget.currentLaptopId) // Exclude current
            .map((doc) => {...doc.data(), 'id': doc.id})
            .take(5) // Show only 5
            .toList();

    setState(() {
      recommendedLaptops = laptops;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (recommendedLaptops.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for You',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...recommendedLaptops.map((laptop) {
            return ListTile(
              title: Text(laptop['brand'] ?? 'N/A'),
              subtitle: Text(laptop['processor'] ?? 'N/A'),
              trailing: Text('LKR. ${laptop['price'] ?? ''}'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LaptopDetailsPage(laptopId: laptop['id']),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
