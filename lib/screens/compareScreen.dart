import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompareScreen extends StatefulWidget {
  final List<String> selectedLaptopIds;
  final Function(List<String>)? onAddMoreLaptops;

  const CompareScreen(String s, {
    required this.selectedLaptopIds,
    this.onAddMoreLaptops,
    super.key,
  });

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  late List<String> selectedLaptopIds;
  List<Map<String, dynamic>> laptops = [];
  bool isLoading = true;

  final List<String> specFields = [
    'display',
    'graphics',
    'memory',
    'storage',
    'processor',
    'price',
    'weight',
  ];

  final Map<String, String> specLabels = {
    'display': 'Display',
    'graphics': 'Graphics',
    'memory': 'Memory',
    'storage': 'Storage',
    'processor': 'Processor',
    'price': 'Price',
    'weight': 'Weight',
  };

  final Map<String, IconData> specIcons = {
    'display': Icons.monitor,
    'graphics': Icons.videogame_asset,
    'memory': Icons.memory,
    'storage': Icons.storage,
    'processor': Icons.developer_board,
    'price': Icons.attach_money,
    'weight': Icons.fitness_center,
  };

  // Method to add new laptops to the current comparison
  void addNewLaptops(List<String> newLaptopIds) {
    // Filter out already selected laptops to avoid duplicates
    final uniqueNewIds =
        newLaptopIds.where((id) => !selectedLaptopIds.contains(id)).toList();

    if (uniqueNewIds.isNotEmpty) {
      setState(() {
        selectedLaptopIds.addAll(uniqueNewIds);
        isLoading = true; // Show loading while fetching new data
      });
      fetchLaptops(); // Refresh to include new laptops
    }
  }

  @override
  void initState() {
    super.initState();
    selectedLaptopIds = List.from(
      widget.selectedLaptopIds,
    ); // make a mutable copy
    fetchLaptops();
  }

  Future<void> fetchLaptops() async {
    if (selectedLaptopIds.isEmpty) {
      setState(() {
        laptops = [];
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('laptops')
              .where(FieldPath.documentId, whereIn: selectedLaptopIds)
              .get();

      setState(() {
        laptops =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching laptops: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Remove laptop by index from the list
  void removeLaptop(int index) {
    setState(() {
      if (index < selectedLaptopIds.length) {
        selectedLaptopIds.removeAt(index);
      }
      if (index < laptops.length) {
        laptops.removeAt(index);
      }
    });
  }

  // Build individual laptop comparison card
  Widget buildLaptopCard(Map<String, dynamic> laptop, int index) {
    String? base64Image;
    if (laptop['imageBase64'] != null &&
        laptop['imageBase64'] is List &&
        laptop['imageBase64'].isNotEmpty) {
      base64Image = laptop['imageBase64'][0].split(',').last;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Header with image, name, and close button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF78B3CE).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24), // Balance the close button
                      Expanded(
                        child: Text(
                          laptop['name'] ?? 'No Name',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => removeLaptop(index),
                        tooltip: 'Remove laptop',
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Laptop image
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          base64Image != null
                              ? Image.memory(
                                base64Decode(base64Image),
                                fit: BoxFit.cover,
                              )
                              : const Icon(
                                Icons.laptop,
                                size: 60,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            // Specifications list
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children:
                    specFields.map((field) {
                      final rawValue =
                          laptop.containsKey(field) && laptop[field] != null
                              ? laptop[field].toString()
                              : 'N/A';
                      final displayValue = formatSpec(field, rawValue);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              specIcons[field] ?? Icons.info,
                              size: 20,
                              color: const Color(0xFF78B3CE),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    specLabels[field] ?? field,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    displayValue,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formatting functions for specs
  String formatProcessor(String? processor) {
    if (processor == null || processor.isEmpty) return 'N/A';
    final parts = processor.split(' ');
    if (parts.length >= 3) {
      return "${parts[0]} ${parts[1]} ${parts[2]}";
    }
    return processor;
  }

  String formatGraphics(String? graphics) {
    if (graphics == null || graphics.isEmpty) return 'N/A';
    final parts = graphics.split(' ');
    if (parts.length >= 2) {
      return "${parts[0]} ${parts[1]}";
    }
    return graphics;
  }

  String formatMemory(String? memory) {
    if (memory == null || memory.isEmpty) return 'N/A';
    final parts = memory.split(' ');
    if (parts.length >= 2) {
      return "${parts[0]} ${parts[1]}";
    }
    return memory;
  }

  String formatStorage(String? storage) {
    if (storage == null || storage.isEmpty) return 'N/A';
    final parts = storage.split(' ');
    if (parts.length >= 2) {
      return "${parts[0]} ${parts[1]}";
    }
    return storage;
  }

  String formatPrice(String? price) {
    if (price == null || price.isEmpty) return 'N/A';
    return price.trim();
  }

  String formatWeight(String? weight) {
    if (weight == null || weight.isEmpty) return 'N/A';
    final parts = weight.split(' ');
    if (parts.length >= 2) {
      return "${parts[0]} ${parts[1]}";
    }
    return weight;
  }

  String formatSpec(String field, String? value) {
    switch (field) {
      case 'processor':
        return formatProcessor(value);
      case 'graphics':
        return formatGraphics(value);
      case 'memory':
        return formatMemory(value);
      case 'storage':
        return formatStorage(value);
      case 'price':
        return formatPrice(value);
      case 'weight':
        return formatWeight(value);
      default:
        if (value == null || value.isEmpty) return 'N/A';
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 227, 230),
      appBar: AppBar(
        title: const Text(
          "Compare Laptops",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF78B3CE),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          // If callback is provided, use it to handle adding more laptops
          if (widget.onAddMoreLaptops != null) {
            widget.onAddMoreLaptops!(selectedLaptopIds);
          } else {
            // Fallback: just go back with current selection
            Navigator.pop(context, selectedLaptopIds);
          }
        },
        backgroundColor: const Color(0xFF78B3CE),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 20),
        tooltip: 'Add Laptop',
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : laptops.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.laptop_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No laptops to compare",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap the + button to add laptops",
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 8),
                    ...laptops.asMap().entries.map(
                      (entry) => buildLaptopCard(entry.value, entry.key),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
    );
  }
}
