import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapwise_catalogue_app/screens/comparisons.dart';

// You'll need to add this import in your actual project
// import 'comparisons_screen.dart';

class CompareScreen extends StatefulWidget {
  final List<String> selectedLaptopIds;
  final Function(List<String>)? onAddMoreLaptops;

  const CompareScreen({
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
  bool _isExpanded = false;

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

  @override
  void initState() {
    super.initState();
    selectedLaptopIds = List.from(
      widget.selectedLaptopIds,
    ); // make a mutable copy
    fetchLaptops();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations or listeners here if needed
    super.dispose();
  }

  // Method to add new laptops to the current comparison
  void addNewLaptops(List<String> newLaptopIds) {
    // Filter out already selected laptops to avoid duplicates
    final uniqueNewIds =
        newLaptopIds.where((id) => !selectedLaptopIds.contains(id)).toList();

    if (uniqueNewIds.isNotEmpty && mounted) {
      setState(() {
        selectedLaptopIds.addAll(uniqueNewIds);
        isLoading = true; // Show loading while fetching new data
      });
      fetchLaptops(); // Refresh to include new laptops
    }
  }

  Future<void> fetchLaptops() async {
    if (selectedLaptopIds.isEmpty) {
      if (mounted) {
        setState(() {
          laptops = [];
          isLoading = false;
        });
      }
      return;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('laptops')
              .where(FieldPath.documentId, whereIn: selectedLaptopIds)
              .get();

      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          laptops =
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching laptops: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Updated method to remove laptop and update Firestore
  Future<void> removeLaptop(String laptopId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please sign in to modify compare list"),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      // Update local state first
      if (mounted) {
        setState(() {
          selectedLaptopIds.remove(laptopId);
          laptops.removeWhere((laptop) => laptop['id'] == laptopId);
        });
      }

      // Update Firestore
      final compareDoc = FirebaseFirestore.instance
          .collection('compare_lists')
          .doc(uid);

      if (selectedLaptopIds.isEmpty) {
        // If no laptops left, delete the document
        await compareDoc.delete();
      } else {
        // Update the document with remaining laptops
        await compareDoc.set({
          'laptopIds': selectedLaptopIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Laptop removed from comparison'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.grey[700],
          ),
        );
      }
    } catch (e) {
      // If Firestore update fails, revert local state
      if (mounted) {
        setState(() {
          selectedLaptopIds.add(laptopId);
        });
        fetchLaptops(); // Refresh to get the laptop back

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing laptop: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Build individual laptop comparison card
  Widget buildLaptopCard(Map<String, dynamic> laptop, int index) {
    String? base64Image;
    if (laptop['imageBase64'] != null &&
        laptop['imageBase64'] is List &&
        laptop['imageBase64'].isNotEmpty) {
      base64Image = laptop['imageBase64'][0].split(',').last;
    }

    final laptopId = laptop['id'] as String;

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
                        onPressed: () {
                          // Show confirmation dialog before removing
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Remove Laptop'),
                                content: Text(
                                  'Are you sure you want to remove "${laptop['name'] ?? 'this laptop'}" from comparison?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await removeLaptop(laptopId);
                                    },
                                    child: const Text(
                                      'Remove',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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

  // Main formatting method that routes to specific formatters
  String formatSpec(String field, String value) {
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
      case 'display':
        return value; // Display can be returned as-is or you can add specific formatting
      default:
        return value;
    }
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

  // Build expandable floating action button
  Widget _buildExpandableFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AI Suggestions button
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _isExpanded = false;
                });
                _showAISuggestions();
              },
              backgroundColor: const Color(0xFF78B3CE),
              foregroundColor: Colors.white,
              label: const Text('AI Suggestions'),
              icon: const Icon(Icons.psychology, size: 20),
              heroTag: "ai_suggestions",
            ),
          ),

        // Save Comparison button
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _isExpanded = false;
                });
                _saveComparison();
              },
              backgroundColor: const Color(0xFF78B3CE),
              foregroundColor: Colors.white,
              label: const Text('Save Comparison'),
              icon: const Icon(Icons.save, size: 20),
              heroTag: "save_comparison",
            ),
          ),

        // Main FAB
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          backgroundColor: const Color(0xFF78B3CE),
          foregroundColor: Colors.white,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(_isExpanded ? Icons.close : Icons.menu, size: 24),
          ),
          heroTag: "main_fab",
        ),
      ],
    );
  }

  // Show AI Suggestions
  void _showAISuggestions() {
    if (laptops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No laptops to analyze for AI suggestions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78B3CE).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, color: Color(0xFF78B3CE)),
                      const SizedBox(width: 12),
                      const Text(
                        'AI Suggestions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSuggestionCard(
                          'Best for Gaming',
                          _getBestForGaming(),
                          Icons.games,
                          Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestionCard(
                          'Best Value for Money',
                          _getBestValue(),
                          Icons.attach_money,
                          Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestionCard(
                          'Most Portable',
                          _getMostPortable(),
                          Icons.laptop_mac,
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestionCard(
                          'Best Performance',
                          _getBestPerformance(),
                          Icons.speed,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSuggestionCard(
    String title,
    String suggestion,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBestForGaming() {
    if (laptops.isEmpty) return 'No laptops to analyze';

    // Simple logic to find laptop with best graphics
    var bestLaptop = laptops.first;
    for (var laptop in laptops) {
      if (laptop['graphics'] != null &&
          laptop['graphics'].toString().toLowerCase().contains('rtx')) {
        bestLaptop = laptop;
        break;
      }
    }
    return '${bestLaptop['name'] ?? 'Unknown'} - Great for gaming with ${bestLaptop['graphics'] ?? 'dedicated graphics'}';
  }

  String _getBestValue() {
    if (laptops.isEmpty) return 'No laptops to analyze';

    // Simple logic to find laptop with lowest price
    var bestValue = laptops.first;
    for (var laptop in laptops) {
      if (laptop['price'] != null) {
        final currentPrice = _extractPrice(laptop['price'].toString());
        final bestPrice = _extractPrice(
          bestValue['price']?.toString() ?? '999999',
        );
        if (currentPrice < bestPrice) {
          bestValue = laptop;
        }
      }
    }
    return '${bestValue['name'] ?? 'Unknown'} - Best value at ${bestValue['price'] ?? 'competitive price'}';
  }

  String _getMostPortable() {
    if (laptops.isEmpty) return 'No laptops to analyze';

    // Simple logic to find lightest laptop
    var mostPortable = laptops.first;
    for (var laptop in laptops) {
      if (laptop['weight'] != null) {
        final currentWeight = _extractWeight(laptop['weight'].toString());
        final bestWeight = _extractWeight(
          mostPortable['weight']?.toString() ?? '999',
        );
        if (currentWeight < bestWeight) {
          mostPortable = laptop;
        }
      }
    }
    return '${mostPortable['name'] ?? 'Unknown'} - Lightweight at ${mostPortable['weight'] ?? 'compact size'}';
  }

  String _getBestPerformance() {
    if (laptops.isEmpty) return 'No laptops to analyze';

    // Simple logic based on processor
    var bestPerformance = laptops.first;
    for (var laptop in laptops) {
      if (laptop['processor'] != null &&
          (laptop['processor'].toString().toLowerCase().contains('i7') ||
              laptop['processor'].toString().toLowerCase().contains('i9') ||
              laptop['processor'].toString().toLowerCase().contains(
                'ryzen 7',
              ) ||
              laptop['processor'].toString().toLowerCase().contains(
                'ryzen 9',
              ))) {
        bestPerformance = laptop;
        break;
      }
    }
    return '${bestPerformance['name'] ?? 'Unknown'} - High performance with ${bestPerformance['processor'] ?? 'powerful processor'}';
  }

  double _extractPrice(String priceStr) {
    final RegExp regex = RegExp(r'[\d,]+');
    final match = regex.firstMatch(priceStr.replaceAll(',', ''));
    return match != null ? double.tryParse(match.group(0) ?? '0') ?? 0 : 0;
  }

  double _extractWeight(String weightStr) {
    final RegExp regex = RegExp(r'[\d.]+');
    final match = regex.firstMatch(weightStr);
    return match != null ? double.tryParse(match.group(0) ?? '0') ?? 0 : 0;
  }

  // Save Comparison with custom name dialog
  void _saveComparison() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please sign in to save comparison"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (laptops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No laptops to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show dialog to get comparison name
    showSaveComparisonDialog();
  }

  void showSaveComparisonDialog() {
    final TextEditingController nameController = TextEditingController(
      text:
          'Comparison ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Comparison'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Give your comparison a name:'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Comparison Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter a name for this comparison',
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This comparison includes:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...laptops
                        .take(3)
                        .map(
                          (laptop) => Text(
                            '• ${laptop['name'] ?? 'Unknown Laptop'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                        .toList(),
                    if (laptops.length > 3)
                      Text(
                        '• + ${laptops.length - 3} more laptops',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                saveComparisonToFirestore(nameController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF78B3CE),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveComparisonToFirestore(String comparisonName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || comparisonName.isEmpty) return;

    try {
      // Save to a saved_comparisons collection
      await FirebaseFirestore.instance
          .collection('saved_comparisons')
          .doc(uid)
          .collection('comparisons')
          .add({
            'laptopIds': selectedLaptopIds,
            'laptopNames':
                laptops.map((laptop) => laptop['name'] ?? 'Unknown').toList(),
            'createdAt': FieldValue.serverTimestamp(),
            'comparisonName': comparisonName,
            'laptopCount': laptops.length,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comparison "$comparisonName" saved successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View All',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to saved comparisons page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComparisonsScreen(),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving comparison: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
          onPressed: () => Navigator.pop(context, selectedLaptopIds),
        ),
      ),
      floatingActionButton: _buildExpandableFAB(),
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
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Horizontal scroll for laptop cards
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children:
                            laptops
                                .asMap()
                                .entries
                                .map(
                                  (entry) =>
                                      buildLaptopCard(entry.value, entry.key),
                                )
                                .toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Add other sections below like table, suggestions etc.
                  ],
                ),
              ),
    );
  }
}
