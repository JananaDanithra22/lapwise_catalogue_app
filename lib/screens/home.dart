import 'package:flutter/material.dart';
import 'lapdetails.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> laptops = [
      {
        'name': 'Series 7',
        'price': '\$799',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Series 4',
        'price': '\$599',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'All Series',
        'price': '\$299',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Pro Series',
        'price': '\$199',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Laptop 5',
        'price': '\$399',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Laptop 6',
        'price': '\$499',
        'image': 'https://via.placeholder.com/150'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF89CFF0),
        leading: const Icon(Icons.menu),
        centerTitle: true,
        title: const Text(
          'Welcome To LapWise',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search laptops...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Centered title
              const Center(
                child: Text(
                  'Find your laptop',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryButton('Laptop'),
                  const SizedBox(width: 12),
                  _buildCategoryButton('Accessories'),
                ],
              ),
              const SizedBox(height: 20),

              // Grid of cards with images
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: laptops.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final item = laptops[index];
                  return _buildLaptopCard(
                    context,
                    item['name']!,
                    item['price']!,
                    item['image']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCategoryButton(String title) {
    return ElevatedButton(
      onPressed: () {
        print('$title button pressed');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(title),
    );
  }

  Widget _buildLaptopCard(
      BuildContext context, String name, String price, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LaptopDetailsPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // ✅ "!" symbol on top-right of image
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Text(
                      '!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              price,
              style: const TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
