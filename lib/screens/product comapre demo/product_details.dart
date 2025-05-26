// product_details_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/compare.store.dart';
import 'compare_popup.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId ;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}



class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? product;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('laptops')
        .doc(widget.productId)
        .get();

    setState(() {
      product = doc.data();
      isLoading = false;
    });
  }

  void addToCompare() {
    CompareStore().add(widget.productId);
    setState(() {}); // refresh to show View Compare
  }

  void showComparePopup() {
    final ids = CompareStore().comparedProductIds;
    showDialog(
      context: context,
      builder: (context) => ComparePopup(selectedIds: ids),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.blue,
        actions: [
          if (CompareStore().comparedProductIds.isNotEmpty)
            TextButton(
              onPressed: showComparePopup,
              child: const Text("View Compare", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: product == null
          ? const Center(child: Text("Product not found"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(product!['image'] ?? ''),
                  const SizedBox(height: 16),
                  Text(product!['name'] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Rs. ${product!['price'] ?? '-'}",
                      style: const TextStyle(fontSize: 18, color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: addToCompare,
                    child: const Text("Compare Product"),
                  ),
                ],
              ),
            ),
    );
  }
}
