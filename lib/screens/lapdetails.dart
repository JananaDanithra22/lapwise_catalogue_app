import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Uint8List> decodedImages = [];

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      'Brand: ${laptopData!['brand'] ?? 'N/A'}',
      'Category: ${laptopData!['category'] ?? 'N/A'}',
    ];

    String price = laptopData!['price'].toString();

    Map<String, dynamic> sellers = Map<String, dynamic>.from(
      laptopData!['sellers'] ?? {},
    );

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
            if (decodedImages.isNotEmpty)
              LaptopImageCarousel(
                imageBytesList: decodedImages,
                pageController: _pageController,
                currentPage: _currentPage,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
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
                  firstChild: SizedBox(
                    width: double.infinity,
                    child: SellerDetailsWidget(sellers: sellers),
                  ),
                  secondChild: SizedBox(
                    width: double.infinity,
                    child: LaptopDetailsBulletPoints(details: specs),
                  ),
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

class LaptopImageCarousel extends StatelessWidget {
  final List<Uint8List> imageBytesList;
  final PageController pageController;
  final int currentPage;
  final Function(int) onPageChanged;

  const LaptopImageCarousel({
    super.key,
    required this.imageBytesList,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: pageController,
            itemCount: imageBytesList.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: MemoryImage(imageBytesList[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imageBytesList.length, (index) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index ? Color(0xFFFFB444) : Colors.grey,
              ),
            );
          }),
        ),
      ],
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
