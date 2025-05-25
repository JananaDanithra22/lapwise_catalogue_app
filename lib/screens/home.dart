import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'lapdetails.dart';
import '../widgets/menubar.dart';
import 'searchresult.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "All Laptops";
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounce;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(_searchController.text.trim());
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    if (input.isEmpty) {
      _clearSuggestions();
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final lowerInput = input.toLowerCase();
      final snapshot =
          await FirebaseFirestore.instance.collection('laptops').get();

      final filtered =
          snapshot.docs
              .where((doc) {
                final data = doc.data();
                final keywords = List<String>.from(data['keywords'] ?? []);
                // Check if any keyword starts with input
                return keywords.any((kw) => kw.startsWith(lowerInput));
              })
              .map((doc) {
                final data = doc.data();
                return {'id': doc.id, 'name': data['name'] ?? 'Unknown Laptop'};
              })
              .toList();

      setState(() {
        _suggestions = filtered;
        _isLoadingSuggestions = false;
      });

      if (_suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        _isLoadingSuggestions = false;
      });
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay?.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width - 24, // account for padding in Scaffold body
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 50),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _isLoadingSuggestions
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : _suggestions.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "No suggestions found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              final name = suggestion['name'] ?? 'Unknown';

                              return ListTile(
                                leading: const Icon(Icons.laptop_outlined),
                                title: Text(name),
                                onTap: () async {
                                  final name = suggestion['name'];
                                  _clearSuggestions();
                                  _searchController.text =
                                      ''; // Clear search before navigating

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => SearchResultPage(query: name),
                                    ),
                                  );

                                  // Also clear again after coming back (just in case)
                                  _searchController.clear();
                                },
                              );
                            },
                          ),
                ),
              ),
            ),
          ),
    );
  }

  void _clearSuggestions() {
    _removeOverlay();
    setState(() {
      _suggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  Stream<QuerySnapshot> _getLaptopStream() {
    final searchText = _searchController.text.trim().toLowerCase();
    CollectionReference laptopsRef = FirebaseFirestore.instance.collection(
      'laptops',
    );

    if (searchText.isNotEmpty) {
      if (selectedCategory == "All Laptops") {
        return laptopsRef
            .where('keywords', arrayContains: searchText)
            .snapshots();
      } else if (selectedCategory == "Gaming Laptops") {
        return laptopsRef
            .where('category', isEqualTo: "Gaming")
            .where('keywords', arrayContains: searchText)
            .snapshots();
      }
    } else {
      if (selectedCategory == "Gaming Laptops") {
        return laptopsRef.where('category', isEqualTo: "Gaming").snapshots();
      } else if (selectedCategory == "All Laptops") {
        return laptopsRef.snapshots();
      }
    }
    return laptopsRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LapWise"),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        backgroundColor: const Color(0xFF78B3CE),
      ),
      drawer: const CustomMenuBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompositedTransformTarget(
              link: _layerLink,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search laptops...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                onTap: () {
                  if (_searchController.text.isNotEmpty &&
                      _suggestions.isNotEmpty) {
                    _showOverlay();
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Find Your Laptop",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ["All Laptops", "Gaming Laptops"].map((cat) {
                    bool isActive = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = cat;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isActive ? Colors.blueAccent : Colors.grey[300],
                          foregroundColor:
                              isActive ? Colors.white : Colors.black,
                        ),
                        child: Text(cat),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getLaptopStream(),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  (_) => LaptopDetailsPage(
                                    laptopId: docs[index].id,
                                  ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child:
                                      imageBytes != null
                                          ? Image.memory(
                                            imageBytes,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            color: const Color.fromARGB(
                                              255,
                                              255,
                                              255,
                                              255,
                                            ),
                                            child: const Icon(
                                              Icons.laptop,
                                              size: 64,
                                              color: Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              ),
                                            ),
                                          ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  "Rs. $price",
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 98, 97, 97),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
