

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
