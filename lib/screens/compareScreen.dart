import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapwise_catalogue_app/screens/comparisons.dart';
import 'package:lapwise_catalogue_app/services/aisuggestion.dart'; // Import AI suggestion service
import 'package:lapwise_catalogue_app/widgets/menubar.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CompareScreen extends StatefulWidget {
  final List<String> selectedLaptopIds;
  final Function(List<String>)? onAddMoreLaptops;

  const CompareScreen( {
    required this.selectedLaptopIds,
    this.onAddMoreLaptops,
    super.key,
  });

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<String> selectedLaptopIds = [];
  List<Map<String, dynamic>> laptops = [];
  bool isLoading = true;
  bool _isExpanded = false;
  bool _isAiLoading = false; // Add this for AI loading state
  String _aiSuggestion = ''; // Add this to store AI suggestion
  bool _isAdmin = false; // Add this to track admin status

  // Initialize AI service
  final AiSuggestionService _aiService = AiSuggestionService();

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
    selectedLaptopIds = List.from(widget.selectedLaptopIds);
    fetchLaptops();
    _checkAdminStatus(); // Check if current user is admin
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Add method to check admin status
  Future<void> _checkAdminStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() {
        _isAdmin = false;
      });
      return;
    }

    try {
      final adminDoc =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();

      if (mounted) {
        setState(() {
          _isAdmin = adminDoc.exists;
        });
      }
    } catch (e) {
      print('Error checking admin status: $e');
      if (mounted) {
        setState(() {
          _isAdmin = false;
        });
      }
    }
  }

  void addNewLaptops(List<String> newLaptopIds) {
    final uniqueNewIds =
        newLaptopIds.where((id) => !selectedLaptopIds.contains(id)).toList();

    if (uniqueNewIds.isNotEmpty && mounted) {
      setState(() {
        selectedLaptopIds.addAll(uniqueNewIds);
        isLoading = true;
      });
      fetchLaptops();
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
      if (mounted) {
        setState(() {
          selectedLaptopIds.remove(laptopId);
          laptops.removeWhere((laptop) => laptop['id'] == laptopId);
        });
      }

      final compareDoc = FirebaseFirestore.instance
          .collection('compare_lists')
          .doc(uid);

      if (selectedLaptopIds.isEmpty) {
        await compareDoc.delete();
      } else {
        await compareDoc.set({
          'laptopIds': selectedLaptopIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

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
      if (mounted) {
        setState(() {
          selectedLaptopIds.add(laptopId);
        });
        fetchLaptops();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing laptop: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                      const SizedBox(width: 24),
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
        return value;
      default:
        return value;
    }
  }

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

  // Updated expandable FAB with admin check and new colors
  Widget _buildExpandableFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Test API Button - Only show for admins
        if (_isExpanded && _isAdmin)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _isExpanded = false;
                });
                _testApiConnection();
              },
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              label: const Text('Test API'),
              icon: const Icon(Icons.wifi_find, size: 20),
              heroTag: "test_api",
            ),
          ),
        // AI Suggestions Button - Updated color
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
              backgroundColor: const Color(0xFFF96E2A), // Changed color
              foregroundColor: Colors.white,
              label: const Text('AI Suggestions'),
              icon: const Icon(Icons.psychology, size: 20),
              heroTag: "ai_suggestions",
            ),
          ),
        // Save Comparison Button - Updated color
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
              backgroundColor: const Color(0xFFF96E2A), // Changed color
              foregroundColor: Colors.white,
              label: const Text('Save Comparison'),
              icon: const Icon(Icons.save, size: 20),
              heroTag: "save_comparison",
            ),
          ),
        // Main FAB - Updated color
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          backgroundColor: const Color(0xFFF96E2A), // Changed color
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

  // Updated AI Suggestions method
  void _showAISuggestions() async {
    if (laptops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No laptops to analyze for AI suggestions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Set loading state and clear previous suggestion
    setState(() {
      _isAiLoading = true;
      _aiSuggestion = '';
    });

    // Generate AI suggestion
    await _generateAISuggestion();

    // Show the modal with AI suggestion
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: !_isAiLoading,
      enableDrag: !_isAiLoading,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
                            const Icon(
                              Icons.psychology,
                              color: Color(0xFF78B3CE),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'AI Suggestions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (!_isAiLoading)
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
                          child:
                              _isAiLoading
                                  ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Color(0xFF78B3CE),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'AI is analyzing your laptops...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.auto_awesome,
                                                    color: Colors.orange[600],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'AI Analysis & Recommendations',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              // Replace Text widget with Markdown widget
                                              _aiSuggestion.isNotEmpty
                                                  ? Markdown(
                                                    data: _aiSuggestion,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    styleSheet:
                                                        MarkdownStyleSheet(
                                                          p: const TextStyle(
                                                            fontSize: 15,
                                                            height: 1.5,
                                                          ),
                                                          h1: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                              0xFF78B3CE,
                                                            ),
                                                          ),
                                                          h2: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                              0xFF78B3CE,
                                                            ),
                                                          ),
                                                          h3: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                              0xFF78B3CE,
                                                            ),
                                                          ),
                                                          strong:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors
                                                                        .black87,
                                                              ),
                                                          listBullet:
                                                              const TextStyle(
                                                                fontSize: 15,
                                                                height: 1.5,
                                                              ),
                                                          blockquote: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                            fontStyle:
                                                                FontStyle
                                                                    .italic,
                                                          ),
                                                        ),
                                                  )
                                                  : const Text(
                                                    'No suggestions available.',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            setModalState(() {
                                              setState(() {
                                                _isAiLoading = true;
                                              });
                                            });
                                            await _generateAISuggestion();
                                            setModalState(() {
                                              setState(() {
                                                _isAiLoading = false;
                                              });
                                            });
                                          },
                                          icon: const Icon(Icons.refresh),
                                          label: const Text(
                                            'Generate New Analysis',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFF96E2A,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  // Method to generate AI suggestion using the service
  Future<void> _generateAISuggestion() async {
    try {
      final promptText = _buildPromptFromLaptops();
      final suggestion = await _aiService.getLaptopComparisonSuggestion(
        promptText,
      );

      if (mounted) {
        setState(() {
          _aiSuggestion = suggestion;
          _isAiLoading = false;
        });
      }
    } catch (e) {
      print('Error generating AI suggestion: $e');
      if (mounted) {
        setState(() {
          _aiSuggestion =
              'Sorry, I encountered an error while analyzing your laptops. Please try again.';
          _isAiLoading = false;
        });
      }
    }
  }

  // Add this method to test API connection
  Future<void> _testApiConnection() async {
    setState(() {
      _isAiLoading = true;
    });

    try {
      final isConnected = await _aiService.testConnection();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isConnected
                  ? 'API connection successful!'
                  : 'API connection failed. Please check your API key.',
            ),
            backgroundColor: isConnected ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection test error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isAiLoading = false;
      });
    }
  }

  // Method to build prompt from laptop data
  String _buildPromptFromLaptops() {
    final StringBuffer prompt = StringBuffer();

    prompt.writeln(
      'Please analyze and compare these laptops, providing detailed recommendations:',
    );
    prompt.writeln('');

    for (int i = 0; i < laptops.length; i++) {
      final laptop = laptops[i];
      prompt.writeln('Laptop ${i + 1}: ${laptop['name'] ?? 'Unknown'}');
      prompt.writeln('- Processor: ${laptop['processor'] ?? 'N/A'}');
      prompt.writeln('- Graphics: ${laptop['graphics'] ?? 'N/A'}');
      prompt.writeln('- Memory: ${laptop['memory'] ?? 'N/A'}');
      prompt.writeln('- Storage: ${laptop['storage'] ?? 'N/A'}');
      prompt.writeln('- Display: ${laptop['display'] ?? 'N/A'}');
      prompt.writeln('- Price: ${laptop['price'] ?? 'N/A'}');
      prompt.writeln('- Weight: ${laptop['weight'] ?? 'N/A'}');
      prompt.writeln('');
    }

    prompt.writeln('Please provide:');
    prompt.writeln('1. Overall comparison summary');
    prompt.writeln('2. Best laptop for gaming');
    prompt.writeln('3. Best value for money');
    prompt.writeln('4. Most portable option');
    prompt.writeln('5. Best for professional work');
    prompt.writeln('6. Detailed pros and cons for each laptop');
    prompt.writeln('7. Your final recommendation based on different use cases');

    return prompt.toString();
  }

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
                backgroundColor: const Color(0xFFF96E2A), // Updated color
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
                  ],
                ),
              ),
    );
  }

  // Method to build formatted text with headers, bullets, etc.
  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    List<Widget> widgets = [];

    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Handle headers
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78B3CE),
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78B3CE),
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line.substring(4),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78B3CE),
              ),
            ),
          ),
        );
      } else if (line.startsWith('🔍 ')) {
        // Handle emoji headers
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78B3CE),
              ),
            ),
          ),
        );
      } else if (line.startsWith('• ') || line.startsWith('- ')) {
        // Handle bullet points
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontSize: 15, color: Color(0xFF78B3CE)),
                ),
                Expanded(child: _buildInlineFormattedText(line.substring(2))),
              ],
            ),
          ),
        );
      } else {
        // Handle regular text with inline formatting
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildInlineFormattedText(line),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // Method to handle inline formatting like **bold**
  Widget _buildInlineFormattedText(String text) {
    List<TextSpan> spans = [];
    int i = 0;

    while (i < text.length) {
      if (i < text.length - 1 && text.substring(i, i + 2) == '**') {
        // Found start of bold text
        int endIndex = text.indexOf('**', i + 2);
        if (endIndex != -1) {
          // Add bold text
          spans.add(
            TextSpan(
              text: text.substring(i + 2, endIndex),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
          i = endIndex + 2;
        } else {
          // No closing **, treat as regular text
          spans.add(TextSpan(text: text[i]));
          i++;
        }
      } else {
        // Find next ** or end of string
        int nextBold = text.indexOf('**', i);
        if (nextBold == -1) nextBold = text.length;

        if (nextBold > i) {
          spans.add(
            TextSpan(
              text: text.substring(i, nextBold),
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          );
        }
        i = nextBold;
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black),
      ),
    );
  }
}
