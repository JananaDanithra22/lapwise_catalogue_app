import 'package:flutter/material.dart';

class LaptopDetailsPage extends StatefulWidget {
  const LaptopDetailsPage({super.key});

  @override
  State<LaptopDetailsPage> createState() => _LaptopDetailsPageState();
}

class _LaptopDetailsPageState extends State<LaptopDetailsPage> {
  bool showReviews = false; // 👈 control whether to show reviews

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Laptop Details'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton( // ✅ Added real back button here
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage( // ✅ Laptop photo
                  image: AssetImage('assets/laptop.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "\$799",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "( With solo loop )",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ColorOption(color: Colors.pinkAccent, label: "Chalk Pink"),
                SizedBox(width: 10),
                ColorOption(color: Colors.blueGrey, label: "Royal Gray", selected: true),
                SizedBox(width: 10),
                ColorOption(color: Colors.green, label: "Eucalyptus"),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      showReviews = false;
                    });
                  },
                  child: const Text(
                    "Details",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showReviews = true;
                    });
                  },
                  child: const Text(
                    "Reviews",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: showReviews 
                  ? Column(
                      children: const [
                        Text(
                          "\"Amazing laptop! Super fast and lightweight.\"",
                          style: TextStyle(color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "\"Battery lasts all day. Highly recommend!\"",
                          style: TextStyle(color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : const Text(
                      "Call it a treasure chest or a mini portable world, handbags are indispensable in daily life.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.orangeAccent],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Add to Compare',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;

  const ColorOption({
    super.key,
    required this.color,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? Colors.white : Colors.transparent,
        side: BorderSide(
          color: selected ? Colors.blueGrey : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () {},
      child: Row(
        children: [
          CircleAvatar(
            radius: 6,
            backgroundColor: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
