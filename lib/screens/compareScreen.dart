import 'package:flutter/material.dart';

void main() {
  runApp(const CompareLaptops());
}

class CompareLaptops extends StatelessWidget {
  const CompareLaptops({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Comparison',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ComparisonPage(),
    );
  }
}

class ComparisonPage extends StatelessWidget {
  const ComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 24),
            _buildProductCards(),
            const SizedBox(height: 24),
            _buildComparisonTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Chip(
          label: const Text('Latest'),
          backgroundColor: Colors.blue[100],
        ),
        Chip(
          label: const Text('Trending'),
          backgroundColor: Colors.grey[200],
        ),
      ],
    );
  }

  Widget _buildProductCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSingleProductCard('Series 7', '\$799'),
        _buildSingleProductCard('Series 7', '\$799'),
        _buildSingleProductCard('Series 7', '\$799'),
      ],
    );
  }

  Widget _buildSingleProductCard(String title, String price) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        border: TableBorder.all(color: Colors.grey[300]!),
        children: [
          _buildTableRow('Brand', ['Hp', 'Dell', 'Mac']),
          _buildTableRow('Internal memory', ['8GB', '6GB', '4GB']),
          _buildTableRow('Internal memory', ['8GB', '6GB', '4GB']),
          _buildTableRow('Internal memory', ['8GB', '6GB', '4GB']),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, List<String> values) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...values.map((value) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(value),
            )),
      ],
    );
  }
}