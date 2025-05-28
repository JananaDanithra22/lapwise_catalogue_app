import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'comparescreen.dart';

class ComparisonsScreen extends StatefulWidget {
  const ComparisonsScreen({super.key});

  @override
  _ComparisonsScreenState createState() => _ComparisonsScreenState();
}

class _ComparisonsScreenState extends State<ComparisonsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> savedComparisons = [];

  @override
  void initState() {
    super.initState();
    fetchSavedComparisons();
  }

  Future<void> fetchSavedComparisons() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('saved_comparisons')
          .doc(uid)
          .collection('comparisons')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        savedComparisons = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching saved comparisons: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteComparison(String comparisonId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('saved_comparisons')
          .doc(uid)
          .collection('comparisons')
          .doc(comparisonId)
          .delete();

      setState(() {
        savedComparisons.removeWhere((comparison) => comparison['id'] == comparisonId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comparison deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting comparison: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void viewComparison(Map<String, dynamic> comparison) {
    final laptopIds = List<String>.from(comparison['laptopIds'] ?? []);
    
    // Navigate to CompareScreen with the saved laptop IDs
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompareScreen(selectedLaptopIds: laptopIds),
      ),
    );
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget buildComparisonCard(Map<String, dynamic> comparison) {
    final laptopNames = List<String>.from(comparison['laptopNames'] ?? []);
    final comparisonName = comparison['comparisonName'] ?? 'Unnamed Comparison';
    final createdAt = comparison['createdAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => viewComparison(comparison),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      comparisonName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF78B3CE),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDeleteConfirmation(comparison);
                      } else if (value == 'rename') {
                        showRenameDialog(comparison);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Rename'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${formatDate(createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.laptop,
                          size: 16,
                          color: Color(0xFF78B3CE),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Laptops compared (${laptopNames.length}):',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...laptopNames.take(3).map((name) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 24),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF78B3CE),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    if (laptopNames.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(left: 36, top: 4),
                        child: Text(
                          '+ ${laptopNames.length - 3} more laptops',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => viewComparison(comparison),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Comparison'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF78B3CE),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDeleteConfirmation(Map<String, dynamic> comparison) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Comparison'),
          content: Text(
            'Are you sure you want to delete "${comparison['comparisonName'] ?? 'this comparison'}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteComparison(comparison['id']);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void showRenameDialog(Map<String, dynamic> comparison) {
    final TextEditingController controller = TextEditingController(
      text: comparison['comparisonName'] ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Comparison'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Comparison Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                renameComparison(comparison['id'], controller.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> renameComparison(String comparisonId, String newName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || newName.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('saved_comparisons')
          .doc(uid)
          .collection('comparisons')
          .doc(comparisonId)
          .update({
        'comparisonName': newName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        final index = savedComparisons.indexWhere((comp) => comp['id'] == comparisonId);
        if (index != -1) {
          savedComparisons[index]['comparisonName'] = newName.trim();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comparison renamed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error renaming comparison: ${e.toString()}'),
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
          "Saved Comparisons",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF78B3CE),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchSavedComparisons,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedComparisons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No saved comparisons",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Save your laptop comparisons to view them here",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchSavedComparisons,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: savedComparisons.length,
                    itemBuilder: (context, index) {
                      return buildComparisonCard(savedComparisons[index]);
                    },
                  ),
                ),
    );
  }
}

// You'll need to import this in your CompareScreen file
// import 'comparisons_screen.dart';