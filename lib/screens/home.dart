import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'lapdetails.dart';
import 'dart:typed_data';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laptop Catalogue')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('laptops')
                .limit(2)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No laptops found.'));
          }

          final laptops = snapshot.data!.docs;

          return ListView.builder(
            itemCount: laptops.length,
            itemBuilder: (context, index) {
              final doc = laptops[index];
              final data = doc.data() as Map<String, dynamic>;

              final price = data['price'] ?? 'N/A';
              final brand = data['brand'] ?? 'Unknown Brand';
              final name = data['name'] ?? 'Laptop';
              final List imageBase64List = data['imageBase64'] ?? [];

              Uint8List? imageBytes;
              if (imageBase64List.isNotEmpty) {
                final cleaned =
                    imageBase64List[0].toString().contains(',')
                        ? imageBase64List[0].toString().split(',')[1]
                        : imageBase64List[0].toString();
                imageBytes = base64Decode(cleaned);
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LaptopDetailsPage(laptopId: doc.id),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                          image:
                              imageBytes != null
                                  ? DecorationImage(
                                    image: MemoryImage(imageBytes),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            imageBytes == null
                                ? const Icon(
                                  Icons.laptop,
                                  size: 40,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text("Brand: $brand"),
                              const SizedBox(height: 6),
                              Text("Price: LKR $price"),
                            ],
                          ),
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
    );
  }
}
