import 'package:flutter/material.dart';

// Product Model
class Product {
  final String series;
  final String price;
  final String imageUrl;
  final bool isLatest;
  final bool isTrending;

  Product({
    required this.series,
    required this.price,
    required this.imageUrl,
    this.isLatest = false,
    this.isTrending = false,
  });
}

// Category Chip Widget
class CategoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF78B3CE) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Product Grid Item Widget
class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(224, 224, 224, 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.series,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF78B3CE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Detail Page
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.network(
              product.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              product.series,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.price,
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF78B3CE),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Product Specifications:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Intel Core i7 Processor\n"
              "• 16GB RAM\n"
              "• 512GB SSD Storage\n"
              "• 15.6\" Full HD Display\n"
              "• Windows 11\n"
              "• Backlit Keyboard\n"
              "• 8 Hours Battery Life",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// HomeScreen
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> products = [
      Product(series: "Series 7", price: "\$799", imageUrl: "https://example.com/laptop1.jpg"),
      Product(series: "Series 4", price: "\$599", imageUrl: "https://example.com/laptop2.jpg", isTrending: true),
      Product(series: "All Series", price: "\$299", imageUrl: "https://example.com/laptop3.jpg"),
      Product(series: "Pro Series", price: "\$199", imageUrl: "https://example.com/laptop4.jpg", isTrending: true),
      Product(series: "Gaming Edition", price: "\$999", imageUrl: "https://example.com/laptop5.jpg", isLatest: true),
      Product(series: "Business Edition", price: "\$899", imageUrl: "https://example.com/laptop6.jpg", isLatest: true),
    ];

    return Scaffold(
      appBar: appBar(),
      drawer: const AppDrawer(),
      body: mainBody(
        context,
        title: "Find your laptop",
        products: products,
        hint: "Search laptops...",
      ),
    );
  }
}

// Common AppBar
AppBar appBar() {
  return AppBar(
    backgroundColor: const Color(0xFF78B3CE),
    centerTitle: true,
    title: const Text(
      "Welcome To LapWise",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  );
}

// Common Body Layout
Widget mainBody(BuildContext context, {required String title, required List<Product> products, required String hint}) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SearchBox(hintText: hint),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          CategoryRow(context),
          const SizedBox(height: 20),
          ProductGrid(products: products),
        ],
      ),
    ),
  );
}

// Drawer Widget
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF78B3CE),
            ),
            child: Center(
              child: Text(
                'LapWise Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          drawerItem(context, "Home", Icons.home, '/'),
          drawerItem(context, "Latest", Icons.fiber_new, '/latest'),
          drawerItem(context, "Trending", Icons.trending_up, '/trending'),
        ],
      ),
    );
  }

  Widget drawerItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}

// Helper Widgets
class SearchBox extends StatelessWidget {
  final String hintText;
  const SearchBox({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}

// Category Row
Widget CategoryRow(BuildContext context) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        CategoryChip(
          label: "Featured",
          onTap: () {},
          isSelected: true,
        ),
        const SizedBox(width: 8),
        CategoryChip(
          label: "Latest",
          onTap: () => Navigator.pushNamed(context, '/latest'),
          isSelected: false,
        ),
        const SizedBox(width: 8),
        CategoryChip(
          label: "Trending",
          onTap: () => Navigator.pushNamed(context, '/trending'),
          isSelected: false,
        ),
      ],
    ),
  );
}

// Product Grid
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductGridItem(
          product: products[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: products[index]),
            ),
          ),
        );
      },
    );
  }
}
