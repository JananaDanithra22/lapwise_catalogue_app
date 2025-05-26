import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapwise_catalogue_app/screens/lapdetails.dart';

class SearchResultPage extends StatelessWidget {
  final String query;

  const SearchResultPage({Key? key, required this.query}) : super(key: key);

  Future<List<Map<String, dynamic>>> _searchLaptops(String query) async {
    final lowerQuery = query.toLowerCase();
    final snapshot =
        await FirebaseFirestore.instance.collection('laptops').get();

    final results =
        snapshot.docs
            .where((doc) {
              final data = doc.data();
              final name = data['name']?.toString().toLowerCase() ?? '';
              final brand = data['brand']?.toString().toLowerCase() ?? '';
              return name.contains(lowerQuery) || brand.contains(lowerQuery);
            })
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            })
            .toList();

    return results;
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes it take full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '👉 (Price range, Brand, Processor filters will go here)',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Apply filter logic here later
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$query"'),
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _searchLaptops(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No laptops found.'));
          }

          final laptops = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: laptops.length,
            itemBuilder: (context, index) {
              final laptop = laptops[index];
              final imageList = laptop['imageBase64'];
              Uint8List? imageBytes;

              if (imageList is List && imageList.isNotEmpty) {
                try {
                  final cleaned =
                      imageList[0].toString().contains(',')
                          ? imageList[0].toString().split(',')[1]
                          : imageList[0];
                  imageBytes = base64Decode(cleaned);
                } catch (e) {
                  print("Image decode error: $e");
                }
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LaptopDetailsPage(laptopId: laptop['id']),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              imageBytes != null
                                  ? Image.memory(
                                    imageBytes,
                                    width: double.infinity,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                  : const Icon(Icons.laptop, size: 80),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          laptop['name'] ?? 'Unknown Laptop',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${laptop['brand'] ?? ''} • ${laptop['processor'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${laptop['gpu'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          'Rs. ${laptop['price'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color.fromARGB(255, 61, 61, 61),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterBottomSheet(context),
        backgroundColor: const Color(0xFFF96E2A), // Orange background
        child: const Icon(
          Icons.filter_list,
          color: Colors.white, // White icon
        ),
      ),
    );
  }
}
