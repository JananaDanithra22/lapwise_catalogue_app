import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'lapdetails.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "Laptop";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LapWise"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Drawer/menu coming soon
          },
        ),
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search laptops...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Find Your Laptop",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["Laptop", "Gaming"].map((cat) {
                bool isActive = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedCategory = cat),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.blueAccent : Colors.grey[300],
                      foregroundColor: isActive ? Colors.white : Colors.black,
                    ),
                    child: Text(cat),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Laptop Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedCategory == "Gaming"
                    ? FirebaseFirestore.instance
                        .collection('laptops')
                        .where('category', isEqualTo: "Gaming")
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('laptops')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text("No laptops found."));
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("No laptops found."));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final rawData = docs[index].data();
                      if (rawData is! Map<String, dynamic>) {
                        print("Invalid document format at index $index");
                        return const SizedBox.shrink();
                      }

                      final data = rawData;
                      final String name = data['name'] ?? 'Laptop';
                      final String price = data['price'] ?? 'N/A';
                      final imageList = data['imageBase64'];
                      Uint8List? imageBytes;

                      if (imageList is List && imageList.isNotEmpty) {
                        try {
                          final imageString = imageList[0].toString();
                          print("🖼 Raw image string for $name: ${imageString.substring(0, 30)}...");

                          final cleaned = imageString.contains(',')
                              ? imageString.split(',')[1]
                              : imageString;

                          imageBytes = base64Decode(cleaned);
                        } catch (e) {
                          print("❌ Image decode error for $name: $e");
                        }
                      } else {
                        print("⚠️ No valid imageBase64 for $name");
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LaptopDetailsPage(laptopId: docs[index].id),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 100,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[200],
                                  image: imageBytes != null
                                      ? DecorationImage(
                                          image: MemoryImage(imageBytes),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: imageBytes == null
                                    ? const Icon(Icons.laptop, size: 40)
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "LKR $price",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
