import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui'; // for blur effect
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapwise_catalogue_app/screens/lapdetails.dart';

class SearchResultPage extends StatefulWidget {
  final String query;
  const SearchResultPage({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List<Map<String, dynamic>> _laptops = [];
  bool _isLoading = true;

  // Add filter state
  double minRam = 0;
  double maxRam = 64;

  Set<String> selectedBrands = {};
  Set<String> selectedProcessors = {};
  double minPrice = 0;
  double maxPrice = 500000;

  // Fixed list of common processors to show in filter
  final List<String> fixedProcessors = [
    'Intel i3',
    'Intel i5',
    'Intel i7',
    'Intel i9',
    'Ryzen 3',
    'Ryzen 5',
    'Ryzen 7',
    'Ryzen 9',
    'M1',
    'M2',
    'M3',
  ];

  @override
  void initState() {
    super.initState();
    _searchLaptops();
  }

  Future<void> _searchLaptops() async {
    final lowerQuery = widget.query.toLowerCase();
    final snapshot =
        await FirebaseFirestore.instance.collection('laptops').get();

    final results =
        snapshot.docs
            .where((doc) {
              final data = doc.data();
              final name = data['name']?.toString().toLowerCase() ?? '';
              final brand = data['brand']?.toString().toLowerCase() ?? '';
              final processor =
                  data['processor']?.toString().toLowerCase() ?? '';
              final priceString = data['price']?.toString() ?? "0";
              final price =
                  double.tryParse(priceString.replaceAll(',', '')) ?? 0;

              // RAM filter: extract numeric GB value from 'memory' string
              final memory = data['memory']?.toString().toLowerCase() ?? '';
              final ramMatch = RegExp(r'(\d+)\s*gb').firstMatch(memory);
              double ram = 0;
              if (ramMatch != null) {
                ram = double.tryParse(ramMatch.group(1) ?? '0') ?? 0;
              }
              final matchesRam = ram >= minRam && ram <= maxRam;

              // Apply keyword filter only if no filters are selected
              final matchesQuery =
                  (selectedBrands.isEmpty && selectedProcessors.isEmpty)
                      ? (widget.query.isEmpty ||
                          name.contains(lowerQuery) ||
                          brand.contains(lowerQuery) ||
                          processor.contains(lowerQuery))
                      : true;

              final matchesBrand =
                  selectedBrands.isEmpty ||
                  selectedBrands.any(
                    (selectedBrand) =>
                        selectedBrand.toLowerCase() == brand.toLowerCase(),
                  );

              final matchesProcessor =
                  selectedProcessors.isEmpty ||
                  selectedProcessors.any(
                    (proc) => processor.contains(proc.toLowerCase()),
                  );

              final matchesPrice = price >= minPrice && price <= maxPrice;

              return matchesQuery &&
                  matchesBrand &&
                  matchesProcessor &&
                  matchesPrice &&
                  matchesRam;
            })
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            })
            .toList();

    setState(() {
      _laptops = results;
      _isLoading = false;
    });
  }

  Future<Map<String, List<String>>> _fetchBrandsOnly() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('laptops').get();
    final brands = <String>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['brand'] != null) brands.add(data['brand']);
    }

    return {'brands': brands.toList()};
  }

  void _openFilterSheet() async {
    // Step 1: Create temporary variables for filter state
    Set<String> tempSelectedBrands = Set.from(selectedBrands);
    Set<String> tempSelectedProcessors = Set.from(selectedProcessors);
    double tempMinPrice = minPrice;
    double tempMaxPrice = maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return FutureBuilder(
                future: _fetchBrandsOnly(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final data = snapshot.data as Map<String, List<String>>;
                  final brands = data['brands']!;
                  final processors =
                      fixedProcessors; // Use fixed processors list here

                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.8,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Filter Here 👇 ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text("Brands"),
                              Wrap(
                                spacing: 8,
                                children:
                                    brands.map((brand) {
                                      return FilterChip(
                                        label: Text(
                                          brand,
                                          style: TextStyle(
                                            color:
                                                tempSelectedBrands.contains(
                                                      brand,
                                                    )
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        selected: tempSelectedBrands.contains(
                                          brand,
                                        ),

                                        selectedColor: Color(
                                          0xFFF96E2A,
                                        ), // Your orange color
                                        backgroundColor: Colors.grey[200],
                                        onSelected: (selected) {
                                          setModalState(() {
                                            selected
                                                ? tempSelectedBrands.add(brand)
                                                : tempSelectedBrands.remove(
                                                  brand,
                                                );
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 10),
                              const Text("Processors"),
                              Wrap(
                                spacing: 8,
                                children:
                                    processors.map((proc) {
                                      return FilterChip(
                                        label: Text(
                                          proc,
                                          style: TextStyle(
                                            color:
                                                tempSelectedProcessors.contains(
                                                      proc,
                                                    )
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        selected: tempSelectedProcessors
                                            .contains(proc),
                                        selectedColor: Color(0xFFF96E2A),
                                        backgroundColor: Colors.grey[200],
                                        onSelected: (selected) {
                                          setModalState(() {
                                            selected
                                                ? tempSelectedProcessors.add(
                                                  proc,
                                                )
                                                : tempSelectedProcessors.remove(
                                                  proc,
                                                );
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 10),
                              const Text("Price Range"),
                              RangeSlider(
                                values: RangeValues(tempMinPrice, tempMaxPrice),
                                min: 0,
                                max: 500000,
                                divisions: 100,
                                labels: RangeLabels(
                                  "Rs. ${tempMinPrice.round()}",
                                  "Rs. ${tempMaxPrice.round()}",
                                ),
                                activeColor: Color(0xFF78B3CE),
                                inactiveColor: Colors.grey[300],
                                onChanged: (values) {
                                  setModalState(() {
                                    tempMinPrice = values.start;
                                    tempMaxPrice = values.end;
                                  });
                                },
                              ),

                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          selectedBrands = tempSelectedBrands;
                                          selectedProcessors =
                                              tempSelectedProcessors;
                                          minPrice = tempMinPrice;
                                          maxPrice = tempMaxPrice;
                                        });
                                        _searchLaptops();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFF96E2A),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("Apply"),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setModalState(() {
                                          tempSelectedBrands.clear();
                                          tempSelectedProcessors.clear();
                                          tempMinPrice = 0;
                                          tempMaxPrice = 500000;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        side: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: const Text("Clear"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "${widget.query}"'),
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _laptops.isEmpty
              ? const Center(child: Text("No laptops found."))
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _laptops.length,
                itemBuilder: (context, index) {
                  final laptop = _laptops[index];
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
                          builder:
                              (_) => LaptopDetailsPage(laptopId: laptop['id']),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  imageBytes != null
                                      ? Image.memory(
                                        imageBytes,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                      : const Icon(Icons.laptop, size: 80),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              laptop['name'] ?? 'Unknown Laptop',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rs. ${laptop['price'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color.fromARGB(255, 61, 61, 61),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF96E2A),
        onPressed: _openFilterSheet,
        child: const Icon(Icons.filter_list, color: Colors.white),
      ),
    );
  }
}
