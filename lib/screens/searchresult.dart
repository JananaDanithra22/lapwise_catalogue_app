import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchResultPage extends StatelessWidget {
  final String query;

  const SearchResultPage({Key? key, required this.query}) : super(key: key);

  Future<List<Map<String, dynamic>>> _searchLaptops(String query) async {
    final lowerQuery = query.toLowerCase();
    final snapshot =
        await FirebaseFirestore.instance.collection('laptops').get();

    print('Total laptops in Firestore: ${snapshot.docs.length}');
    print('Search query: "$lowerQuery"');

    final results =
        snapshot.docs
            .where((doc) {
              final data = doc.data();
              final name = data['name']?.toString().toLowerCase() ?? '';
              final brand = data['brand']?.toString().toLowerCase() ?? '';
              return name.contains(lowerQuery) || brand.contains(lowerQuery);
            })
            .map((doc) => doc.data())
            .toList();

    print('Filtered results: ${results.length}');
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
              final imageBase64 = laptop['imageBase64'] ?? '';
              final name = laptop['name'] ?? 'Unknown';
              final price = laptop['price'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ListTile(
                  leading:
                      imageBase64.isNotEmpty
                          ? Image.memory(
                            base64Decode(imageBase64),
                            width: 60,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.laptop),
                  title: Text(name),
                  subtitle: Text('Rs. $price'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
