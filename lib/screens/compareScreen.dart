import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:lapwise_catalogue_app/screens/lapdetails.dart';
import 'package:lapwise_catalogue_app/widgets/button.dart';
import 'package:lapwise_catalogue_app/widgets/button.dart';

//line no 89 for AI suggestions

class ComparePopup extends StatelessWidget {
  final List<String> selectedIds;
  const ComparePopup({super.key, required this.selectedIds});

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('laptops')
            .where(FieldPath.documentId, whereIn: selectedIds)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Compared Products"),
      icon: IconButton(
        icon: const Icon(Icons.close, color: Colors.red),
        onPressed: () {
          Navigator.of(context).pop(); // 🔥 Close the popup
        },
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No products found");
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

                      //avoid overflow
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          //allproduct details show
                          children: [
                            ProductCard(product: product),
                            const SizedBox(height: 10),
                            // InfoRow(label: "Brand", value: product['brand'] ?? "-"),
                            // InfoRow(label: "Display", value: product['display'] ?? "-"),
                            InfoRow(
                              label: "Memory",
                              value: product['memory'] ?? "-",
                            ),
                            InfoRow(label: "OS", value: product['os'] ?? "-"),
                            InfoRow(
                              label: "Processor",
                              value: product['processor'] ?? "-",
                            ),
                            InfoRow(
                              label: "Graphics",
                              value: product['graphics'] ?? "-",
                            ),

                          This is for AI 

                            InfoRow(
                              label: "AI Suggestions",
                              value: product['aiSuggestions']?.join(', ') ?? "-",
                            ),

                            //sellers
                            const SizedBox(height: 10),
                            // const Text("Sellers:", style: TextStyle(fontWeight: FontWeight.bold)),

                            // ...(product['sellers'] as Map<String, dynamic>? ?? {}).entries.map((entry) {
                            //   final sellerName = entry.key;
                            //   final seller = entry.value;

                            //   if (seller is Map<String, dynamic>) {
                            //     return Padding(
                            //       padding: const EdgeInsets.only(bottom: 6.0),
                            //       child: Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           Text("• $sellerName", style: const TextStyle(fontWeight: FontWeight.w600)),
                            //           Text("Website: ${seller['WEB'] ?? '-'}"),
                            //           Text("Address: ${seller['ADDRESS'] ?? '-'}"),
                            //           Text("Phone: ${seller['PHONE'] ?? '-'}"),
                            //         ],
                            //       ),
                            //     );
                            // } else {
                            //   return Text("• $sellerName - $seller");
                            // }
                            //   }).toList(),
                          ],
                        ),
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
      ),
    );
  }
}

// class ProductComparisonScreen extends StatelessWidget {
//   final List<String> selectedProductIds;

//   const ProductComparisonScreen({super.key, required this.selectedProductIds});

//   Future<List<Map<String, dynamic>>> fetchProducts() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('laptops')
//         .where(FieldPath.documentId, whereIn: selectedProductIds)
//         .get();

//     return snapshot.docs.map((doc) => doc.data()).toList();
//   }

// }

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Decode images if available
    final imageBase64List = List<String>.from(product['imageBase64'] ?? []);
    final decodedImages =
        imageBase64List.map((base64Image) {
          final cleaned =
              base64Image.contains(',')
                  ? base64Image.split(',')[1]
                  : base64Image;
          return base64Decode(cleaned);
        }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Optionally display the first image if available
            if (decodedImages.isNotEmpty)
              Image.memory(decodedImages.first, height: 100, fit: BoxFit.cover),
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
                  index < (product['rating'] ?? 0).round()
                      ? Icons.star
                      : Icons.star_border,
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
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
          child: DynamicButtonStyle(
            buttonTitle: 'Add Product',

            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
