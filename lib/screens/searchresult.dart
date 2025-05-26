import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
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

          return ListView.builder(
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              imageBytes != null
                                  ? Image.memory(
                                    imageBytes,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                  : const Icon(Icons.laptop, size: 60),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                laptop['name'] ?? 'Unknown Laptop',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${laptop['brand'] ?? ''} • ${laptop['processor'] ?? ''}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${laptop['gpu'] ?? ''}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rs. ${laptop['price'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
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
    );
  }
}
