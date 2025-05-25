import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> generateAndAddKeywordsToLaptops() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final QuerySnapshot snapshot = await firestore.collection('laptops').get();

  for (final doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;

    final name = data['name'] ?? '';
    final brand = data['brand'] ?? '';
    final processor = data['processor'] ?? '';
    final graphics = data['graphics'] ?? '';
    final category = data['category'] ?? '';
    final display = data['display'] ?? '';
    final os = data['os'] ?? '';
    final storage = data['storage'] ?? '';
    final memory = data['memory'] ?? '';

    // Combine all into one string
    final combined = "$name $brand $processor $graphics $category $display $os $storage $memory";

    final keywords = _generateKeywords(combined);

    // Update document with new keywords
    await firestore.collection('laptops').doc(doc.id).set({
      'searchKeywords': keywords,
    }, SetOptions(merge: true));

    print('✅ Added keywords to: ${doc.id}');
  }
}

List<String> _generateKeywords(String input) {
  final words = input.toLowerCase().split(RegExp(r'[^a-zA-Z0-9]+'));
  final Set<String> keywords = {};

  for (int i = 0; i < words.length; i++) {
    keywords.add(words[i]); // single word
    if (i < words.length - 1) {
      keywords.add('${words[i]} ${words[i + 1]}'); // two-word phrases
    }
  }

  return keywords.where((w) => w.trim().isNotEmpty).toList();
}
