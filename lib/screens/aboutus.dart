import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.pushNamed(context, '/home'); // 👈 Go to HomePage
          },
        ),
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: const Color(0xFF78B3CE),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFC9E6F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  height: 250.0,
                  width: 250.0,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'LapWise Catalogue App is designed to simplify your laptop search experience in Sri Lanka. '
                'We offer a comprehensive collection of the latest laptops along with detailed specifications and trusted seller information. '
                'While purchases are not made directly through our app, we connect you with verified sellers and help you make informed decisions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 40.0),
              const Text(
                'Contact Us:\n\n'
                'Email: support@lapwise.com\n'
                'Phone: +1 234 567 890\n'
                'Address: 123 LapWise St, Tech City, 456789',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: const Color.fromARGB(255, 25, 67, 184),
                thickness: 3,
                height: 30,
                // space for the divider itself + padding
              ),
              const SizedBox(height: 40.0),
              const teamIntro(),
              const SizedBox(height: 20.0),
              TeamMembersIntro(),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamMembersIntro extends StatelessWidget {
  const TeamMembersIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // vertical scroll if needed
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // First row of team members
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text('Janana - Developer'),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text('Thishmika - Designer'),
                  ],
                ),
              ],
            ),

            SizedBox(height: 40), // spacing between rows

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // First row of team members
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text('Tharidu - Developer'),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text('Ayodya - Developer'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40), // spacing between rows

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // First row of team members
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text('Hiranya - Developer'),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text('Punarji - Designer'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40), // spacing between rows

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // First row of team members
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text('Imesh - Developer'),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/user.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text('username - Designer'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class teamIntro extends StatelessWidget {
  const teamIntro({super.key});

  @override
  Widget build(BuildContext context) {
    // Bouncing effect for vertical scroll

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: const [
          Text(
            'Meet The Team Behind LapWise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 14, 65, 88),
            ),
          ),
          Text(
            'This app was developed as part of our Mobile Application Development Module in the 3rd year. '
            'We worked together to create a user-friendly platform to help you Compare laptops easily with AI assistance.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
