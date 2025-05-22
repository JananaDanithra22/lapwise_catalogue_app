import 'package:flutter/material.dart';
import '../widgets/menubar.dart';
import 'searchresult.dart'; // ✅ Import your SearchResultPage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  void _startSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultPage(query: query), // ✅ Named parameter
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search query.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LapWise Home'),
        centerTitle: true,
        backgroundColor: const Color(0xFF78B3CE),
      ),
      drawer: const CustomMenuBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to LapWise Catalogue App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Explore latest laptops and find your perfect match!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search laptops by name or brand',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _startSearch(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _startSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF78B3CE),
              ),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
