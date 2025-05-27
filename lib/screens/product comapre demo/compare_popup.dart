// compare_popup.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComparePopup extends StatelessWidget {
  final List<String> selectedIds;
  const ComparePopup({super.key, required this.selectedIds});

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('laptops')
        .where(FieldPath.documentId, whereIn: selectedIds)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Compared Products"),
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
                children: products.map((product) {
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(product['image'] ?? '', height: 100),
                        const SizedBox(height: 8),
                        Text(product['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Price: Rs. ${product['price'] ?? '-'}"),
                        Text("Processor: ${product['processor'] ?? '-'}"),
                        Text("Memory: ${product['memory'] ?? '-'}"),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
