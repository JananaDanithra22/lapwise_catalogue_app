import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompareScreen extends StatefulWidget {
  final List<String> selectedLaptopIds;

  const CompareScreen({required this.selectedLaptopIds, super.key});

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
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

  @override
  void initState() {
    super.initState();
    fetchLaptops();
  }

  Future<void> fetchLaptops() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('laptops')
              .where(FieldPath.documentId, whereIn: widget.selectedLaptopIds)
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

  void removeLaptop(int index) {
    setState(() {
      laptops.removeAt(index);
    });
  }

  Widget buildLaptopHeader(Map<String, dynamic> laptop, int index) {
    String? base64Image;
    if (laptop['imageBase64'] != null &&
        laptop['imageBase64'] is List &&
        laptop['imageBase64'].isNotEmpty) {
      base64Image = laptop['imageBase64'][0].split(',').last;
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          base64Image != null
              ? Image.memory(
                base64Decode(base64Image),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
              : Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.laptop, size: 50),
              ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => removeLaptop(index),
          ),
          Text(
            laptop['name'] ?? 'No Name',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : laptops.isEmpty
              ? const Center(child: Text("No laptops to compare."))
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 120),
                          ...laptops.asMap().entries.map(
                            (entry) =>
                                buildLaptopHeader(entry.value, entry.key),
                          ),
                        ],
                      ),
                      Table(
                        columnWidths: const {0: FixedColumnWidth(120)},
                        border: TableBorder.all(color: Colors.grey),
                        children:
                            specFields.map((field) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      specLabels[field] ?? field,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...laptops.map((laptop) {
                                    // FIXED: ensure the field exists and handle string formatting
                                    final value =
                                        laptop.containsKey(field) &&
                                                laptop[field] != null
                                            ? laptop[field].toString()
                                            : 'N/A';
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 160, // adjust as needed
                                        child: Text(
                                          value,
                                          style: const TextStyle(fontSize: 13),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
