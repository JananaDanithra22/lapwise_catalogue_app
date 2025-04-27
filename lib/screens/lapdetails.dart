import 'package:flutter/material.dart';

class LaptopDetailsPage extends StatefulWidget {
  const LaptopDetailsPage({super.key});

  @override
  State<LaptopDetailsPage> createState() => _LaptopDetailsPageState();
}

class _LaptopDetailsPageState extends State<LaptopDetailsPage> {
  bool showReviews = false;
  String selectedColorLabel = "Royal Gray"; // default selected color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Laptop Details'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
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
                image: const DecorationImage(
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
            Text(
              "($selectedColorLabel)", // show selected color here
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorOption(
                  color: Colors.pinkAccent,
                  label: "Chalk Pink",
                  selected: selectedColorLabel == "Chalk Pink",
                  onSelected: () {
                    setState(() {
                      selectedColorLabel = "Chalk Pink";
                    });
                  },
                ),
                const SizedBox(width: 10),
                ColorOption(
                  color: Colors.blueGrey,
                  label: "Royal Gray",
                  selected: selectedColorLabel == "Royal Gray",
                  onSelected: () {
                    setState(() {
                      selectedColorLabel = "Royal Gray";
                    });
                  },
                ),
                const SizedBox(width: 10),
                ColorOption(
                  color: Colors.green,
                  label: "Eucalyptus",
                  selected: selectedColorLabel == "Eucalyptus",
                  onSelected: () {
                    setState(() {
                      selectedColorLabel = "Eucalyptus";
                    });
                  },
                ),
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
                  child: Text(
                    "Details",
                    style: TextStyle(
                      color: showReviews ? Colors.grey : Colors.blueAccent,
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
                  child: Text(
                    "Reviews",
                    style: TextStyle(
                      color: showReviews ? Colors.blueAccent : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
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
                  : const LaptopDetailsBulletPoints(),
              ),
            ),
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
                        colors: [Colors.blueAccent, Color.fromARGB(255, 64, 163, 255)],
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
  final VoidCallback onSelected;

  const ColorOption({
    super.key,
    required this.color,
    required this.label,
    this.selected = false,
    required this.onSelected,
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
      onPressed: onSelected,
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

class LaptopDetailsBulletPoints extends StatelessWidget {
  const LaptopDetailsBulletPoints({super.key});

  final List<String> details = const [
    "AMD Ryzen™ 5 7520U Mobile Processor 2.8GHz (4-core/8-thread, 4MB cache, up to 4.3 GHz max boost)",
    "8GB DDR5 5200MHZ Memory.",
    "AMD Radeon Integrated Graphics.",
    "512GB PCIE 4.0 NVME SSD (Upgradable).",
    "15.6-inch, FHD (1920 x 1080) 16:9 aspect ratio, LED Backlit, 60Hz refresh rate, 250nits.",
    "Chiclet Keyboard, 1.4mm Key-travel, Precision touchpad.",
    "HD 720p camera, integrated dual array microphones with privacy shutter.",
    "SonicMaster Built-in speaker.",
    "Wi-Fi 6E (802.11ax) (Dual band) 1*1 + Bluetooth® 5.3 Wireless Card.",
    "USB 2.0 Type-A / USB 3.2 Gen 1 Type-C / USB 3.2 Gen 1 Type-A / HDMI 1.4.",
    "Genuine Windows 11 License.",
    "42WHrs, 3S1P, 3-cell Li-ion Battery.",
    "45W AC Adapter, Output: 19V DC, 2.37A, 45W, Input: 100~240V AC 50/60Hz.",
    "1.70 kg (3.75 lbs) Weight.",
    "Silver Green Color.",
    "3 Years Warranty (1 Year Hardware + 2 Years Service Warranty).",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((detail) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 16, color: Colors.black)),
            Expanded(
              child: Text(
                detail,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
