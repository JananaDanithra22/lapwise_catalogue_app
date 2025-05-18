
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProductComparisonApp());
}

class ProductComparisonApp extends StatelessWidget {
  const ProductComparisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductComparisonScreen(
        selectedProductIds: [
          '7tY2XDTbJojNWKrhscfM',
          'BlOc9P1YmR8GkqodSfu4',
        ],
      ),
    );
  }
}

class ProductComparisonScreen extends StatelessWidget {
  final List<String> selectedProductIds;

  const ProductComparisonScreen({super.key, required this.selectedProductIds});

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('laptops')
        .where(FieldPath.documentId, whereIn: selectedProductIds)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PRODUCT COMPARISON"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          final products = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...products.map((product) {
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductCard(product: product),
                        const SizedBox(height: 10),
                        InfoRow(label: "Brand", value: product['brand'] ?? "-"),
                        InfoRow(label: "Display", value: product['display'] ?? "-"),
                        InfoRow(label: "Graphics", value: product['graphics'] ?? "-"),
                        InfoRow(label: "Memory", value: product['memory'] ?? "-"),
                        InfoRow(label: "OS", value: product['os'] ?? "-"),
                        InfoRow(label: "Processor", value: product['processor'] ?? "-"),
                        const SizedBox(height: 10),
                        const Text("Sellers:", style: TextStyle(fontWeight: FontWeight.bold)),

                        ...(product['sellers'] as Map<String, dynamic>? ?? {}).entries.map((entry) {
                          final sellerName = entry.key;
                          final seller = entry.value;

                          if (seller is Map<String, dynamic>) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("• $sellerName", style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text("Website: ${seller['WEB'] ?? '-'}"),
                                  Text("Address: ${seller['ADDRESS'] ?? '-'}"),
                                  Text("Phone: ${seller['PHONE'] ?? '-'}"),
                                ],
                              ),
                            );
                          } else {
                            return Text("• $sellerName - $seller");
                          }
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),

                // Add product button
                Container(
                  width: 220,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  child: const AddProductButton(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🔹 Product Card Widget
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Image.network(
              product['image'] ?? 'https://via.placeholder.com/150',
              height: 100,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
            ),
            const SizedBox(height: 10),
            Text(
              product['name'] ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  index < (product['rating'] ?? 0).round() ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Rs. ${product['price'] ?? '-'}",
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Info Row Widget
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// 🔹 Add Button Widget
class AddProductButton extends StatelessWidget {
  const AddProductButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SizedBox(
        height: 250,
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Show dialog or navigate to product picker
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade700),
            child: const Text("Add Product"),
          ),
        ),
      ),
    );
  }
}

