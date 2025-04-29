import 'package:flutter/material.dart';
import 'lapdetails.dart'; // Import LaptopDetailsPage

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Column(
        children: [
          const Center(
            child: Text(
              'Welcome to Home Page!',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Pass a sample laptop ID to the details page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          LaptopDetailsPage(laptopId: 'VDnDKgDAZBsyKhLZRbf2'),
                ),
              );
            },
            child: const Text('View Laptop Details'),
          ),
        ],
      ),
    );
  }
}
