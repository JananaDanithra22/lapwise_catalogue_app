import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'home.dart';
import 'laprec.dart';
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
    if (uid == null) return;

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
    if (uid == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.laptopId);

    String message;

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
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
      'Category: ${laptopData!['category'] ?? 'N/A'}',
      'Brand: ${laptopData!['brand'] ?? 'N/A'}',
      'Processor: ${laptopData!['processor'] ?? 'N/A'}',
      'Storage: ${laptopData!['storage'] ?? 'N/A'}',
      'Memory: ${laptopData!['memory'] ?? 'N/A'}',
      'Display: ${laptopData!['display'] ?? 'N/A'}',
      'Graphics: ${laptopData!['graphics'] ?? 'N/A'}',
      'Operating System: ${laptopData!['os'] ?? 'N/A'}',
      'Weight: ${laptopData!['weight'] ?? 'N/A'}',
    ];

    String price = laptopData!['price'].toString();
    String laptopName = laptopData!['name'] ?? 'Unknown Laptop';
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (decodedImages.isNotEmpty)
                Stack(
                  children: [
                    _LaptopImageCarousel(
                      imageBytesList: decodedImages,
                      pageController: _pageController,
                      currentPage: _currentPage,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        icon: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorited ? Color(0xFFFFB444) : Colors.grey,
                          size: 30,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ],
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
                laptopName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
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
                            showSellersDetails
                                ? Colors.grey
                                : Colors.blueAccent,
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
                            showSellersDetails
                                ? Colors.blueAccent
                                : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
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
                  firstChild: _SellerDetailsWidget(sellers: sellers),
                  secondChild: _LaptopDetailsBulletPoints(details: specs),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
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
              _LaptopRecommendations(
                category: laptopData!['category'] ?? '',
                currentLaptopId: widget.laptopId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Image Carousel Widget
class _LaptopImageCarousel extends StatelessWidget {
  final List<Uint8List> imageBytesList;
  final PageController pageController;
  final int currentPage;
  final Function(int) onPageChanged;

  const _LaptopImageCarousel({
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
          height: 250,
          child: PageView.builder(
            controller: pageController,
            itemCount: imageBytesList.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(imageBytesList[index], fit: BoxFit.cover),
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
                color: currentPage == index ? Colors.blueAccent : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }
}

// Bullet Points for Laptop Details Widget
class _LaptopDetailsBulletPoints extends StatelessWidget {
  final List<String> details;

  const _LaptopDetailsBulletPoints({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          details.map((item) {
            // Split field name and value
            List<String> split = item.split(": ");
            String fieldName = split[0];
            String fieldValue = split.length > 1 ? split[1] : "N/A";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 16)),
                  Text(
                    "$fieldName: ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Bold for the field name
                    ),
                  ),
                  Expanded(
                    child: Text(
                      fieldValue,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

// Seller Details Widget
class _SellerDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> sellers;

  const _SellerDetailsWidget({super.key, required this.sellers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          sellers.entries.map((entry) {
            String sellerName = entry.key;
            dynamic sellerDetails = entry.value;

            if (sellerDetails is Map<String, dynamic>) {
              String website = sellerDetails['website'] ?? 'Not available';
              String address = sellerDetails['address'] ?? 'Not available';
              String phone = sellerDetails['phone'] ?? 'Not available';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'WEB: ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Bold label
                    Text(website, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      'ADDRESS: ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Bold label
                    Text(address, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      'PHONE: ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Bold label
                    Text(phone, style: const TextStyle(fontSize: 16)),
                    const Divider(color: Colors.grey, thickness: 1),
                  ],
                ),
              );
            } else {
              // Handle the case where sellerDetails is a string (not a map)
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sellerDetails.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(color: Colors.grey, thickness: 1),
                  ],
                ),
              );
            }
          }).toList(),
    );
  }
}

// Recommendations Widget
class _LaptopRecommendations extends StatelessWidget {
  final String category;
  final String currentLaptopId;

  const _LaptopRecommendations({
    super.key,
    required this.category,
    required this.currentLaptopId,
  });

  @override
  Widget build(BuildContext context) {
    return LaptopRecommendationSection(
      category: category,
      currentLaptopId: currentLaptopId,
    );
  }
}

// Laptop Recommendation Section Widget
class LaptopRecommendationSection extends StatefulWidget {
  final String category;
  final String currentLaptopId;

  const LaptopRecommendationSection({
    super.key,
    required this.category,
    required this.currentLaptopId,
  });

  @override
  State<LaptopRecommendationSection> createState() =>
      _LaptopRecommendationSectionState();
}

class _LaptopRecommendationSectionState
    extends State<LaptopRecommendationSection> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More to Love 🔥',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          VisibilityDetector(
            key: const Key('recommendation-section'),
            onVisibilityChanged: (info) {
              if (mounted) {
                // Check if the widget is still in the tree
                if (info.visibleFraction > 0.1 && !_isVisible) {
                  setState(() {
                    _isVisible = true;
                  });
                } else if (info.visibleFraction < 0.05 && _isVisible) {
                  setState(() {
                    _isVisible = false;
                  });
                }
              }
            },

            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _isVisible ? 1.0 : 0.0,
              curve: Curves.easeInOut,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('laptops')
                        .where('category', isEqualTo: widget.category)
                        .where(
                          FieldPath.documentId,
                          isNotEqualTo: widget.currentLaptopId,
                        )
                        .limit(5)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading recommendations'),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No recommendations available.'),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var laptop = docs[index].data() as Map<String, dynamic>;

                      String name = laptop['name'] ?? 'Unnamed Laptop';
                      String price = laptop['price'].toString();
                      String base64Image = laptop['imageBase64'][0] ?? '';
                      Uint8List? decodedImage;

                      if (base64Image.isNotEmpty) {
                        final cleaned =
                            base64Image.contains(',')
                                ? base64Image.split(',')[1]
                                : base64Image;
                        decodedImage = base64Decode(cleaned);
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => LaptopDetailsPage(
                                    laptopId: docs[index].id,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (decodedImage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    decodedImage,
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                const Icon(Icons.image_not_supported, size: 60),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "LKR.$price",
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
