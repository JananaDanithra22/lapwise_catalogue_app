import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'home.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:lapwise_catalogue_app/widgets/compare.store.dart';
import 'package:lapwise_catalogue_app/screens/compareScreen.dart';

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
        const SnackBar(content: Text("Laptop not fucking found in Firestore.")),
      );
    }
  }

  Future<void> _checkIfFavorite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() {
        _isFavorited = false;
      });
      return;
    }

    final query =
        await FirebaseFirestore.instance
            .collection('favourites')
            .where('userId', isEqualTo: uid)
            .where('laptopId', isEqualTo: widget.laptopId)
            .get();

    if (mounted) {
      setState(() {
        _isFavorited = query.docs.isNotEmpty;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please sign in to use favourites"),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

     final favCollection = FirebaseFirestore.instance.collection('favourites');

         try {
      // Check if this laptop is already in favourites
      final query =
          await favCollection
              .where('userId', isEqualTo: uid)
              .where('laptopId', isEqualTo: widget.laptopId)
              .get();

      if (query.docs.isNotEmpty) {
        // Exists → remove it
        await favCollection.doc(query.docs.first.id).delete();
        setState(() {
          _isFavorited = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Removed from Favourites 💔")),
        );
      } else {
        // Not exists → add it
        await favCollection.add({
          'userId': uid,
          'laptopId': widget.laptopId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isFavorited = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to Favourites 💛")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
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

    //set loading state to false
    void addToCompare() {
      setState(() {
        CompareStore().add(widget.laptopId);
      });
      print('Added to compare: ${widget.laptopId}');
    }

    //add pop up page to pop up compare added products

    void showComparePopup() {
      final ids = CompareStore().comparedProductIds;
      showDialog(
        context: context,
        builder: (context) => ComparePopup(selectedIds: ids),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 227, 230),
      appBar: AppBar(
        title: const Text(
          'Laptop Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF78B3CE),
        actions: [
          if (CompareStore().comparedProductIds.isNotEmpty)
            TextButton(
              onPressed: showComparePopup,
              child: const Text(
                "View Compare",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],

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
                  height: 50,
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
                "LKR.$price",
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
                        fontSize: 17, // Increased font size
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
                        fontSize: 17, // Increased font size
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
                      String base64Image = '';
                      if (laptop['imageBase64'] is List &&
                          (laptop['imageBase64'] as List).isNotEmpty) {
                        base64Image = laptop['imageBase64'][0] ?? '';
                      }

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
