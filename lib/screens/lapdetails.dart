import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Import your Home page
import 'dart:convert';
import 'dart:typed_data';

class LaptopDetailsPage extends StatefulWidget {
  final String laptopId;

  const LaptopDetailsPage({super.key, required this.laptopId});

  @override
  State<LaptopDetailsPage> createState() => _LaptopDetailsPageState();
}

class _LaptopDetailsPageState extends State<LaptopDetailsPage> {
  bool showSellersDetails = false;
  Map<String, dynamic>? laptopData;

  @override
  void initState() {
    super.initState();
    fetchLaptopData();
  }

  Future<void> fetchLaptopData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('laptops')
            .doc(widget.laptopId)
            .get();

    if (doc.exists) {
      setState(() {
        laptopData = doc.data();
      });
    } else {
      // Handle missing document
      setState(() {
        laptopData = {}; // Empty map just to stop spinner
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Laptop not found in Firestore.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (laptopData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<String> specs = [
      'Processor: ${laptopData!['processor'] ?? 'N/A'}',
      'Storage: ${laptopData!['storage'] ?? 'N/A'}',
      'Memory: ${laptopData!['memory'] ?? 'N/A'}',
      'Display: ${laptopData!['display'] ?? 'N/A'}',
      'Graphics: ${laptopData!['graphics'] ?? 'N/A'}',
      'Weight: ${laptopData!['weight'] ?? 'N/A'}',
      'Operating System: ${laptopData!['os'] ?? 'N/A'}',
    ];

    String price = laptopData!['price'].toString();
    String? base64Image =
        laptopData!['imageBase64']; // The base64 image string from Firestore
    Map<String, dynamic> sellers = Map<String, dynamic>.from(
      laptopData!['sellers'] ?? {},
    );

    // Decode base64 image
    Uint8List? imageBytes;
    if (base64Image != null) {
      // Extract the actual base64 data from the string (remove prefix)
      String imageData = base64Image.replaceFirst(
        'data:image/jpeg;base64,',
        '',
      );
      imageBytes = base64Decode(imageData);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Laptop Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF78B3CE),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display image using MemoryImage if imageBytes is available
            if (imageBytes != null)
              Container(
                margin: const EdgeInsets.all(16),
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: MemoryImage(imageBytes), // Display image from base64
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.all(16),
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "No image available",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              "\LKR.$price",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(() => showSellersDetails = false),
                  child: Text(
                    "Specifications",
                    style: TextStyle(
                      color:
                          showSellersDetails ? Colors.grey : Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => showSellersDetails = true),
                  child: Text(
                    "Sellers Details",
                    style: TextStyle(
                      color:
                          showSellersDetails ? Colors.blueAccent : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 10,
                ),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 400),
                  crossFadeState:
                      showSellersDetails
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  firstChild: SellerDetailsWidget(sellers: sellers),
                  secondChild: LaptopDetailsBulletPoints(details: specs),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFB444), Color(0xFFFFA640)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: const Center(
                      child: Text(
                        'Add to Compare',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LaptopDetailsBulletPoints extends StatelessWidget {
  final List<String> details;
  const LaptopDetailsBulletPoints({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          details.map((detail) {
            final splitIndex = detail.indexOf(':');
            String label =
                splitIndex != -1 ? detail.substring(0, splitIndex + 1) : '';
            String value =
                splitIndex != -1
                    ? detail.substring(splitIndex + 1).trim()
                    : detail;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: label + ' ',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: value,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

class SellerDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> sellers;
  const SellerDetailsWidget({super.key, required this.sellers});

  @override
  Widget build(BuildContext context) {
    if (sellers.isEmpty) {
      return const Text("No seller info available.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          sellers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(entry.value, style: const TextStyle(fontSize: 16)),
                  const Divider(thickness: 1, height: 20),
                ],
              ),
            );
          }).toList(),
    );
  }
}
