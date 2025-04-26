import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 👈 LEFT ALIGN texts
            children: [
              const SizedBox(height: 30),
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/lapwiselogo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 30),
              // Welcome Text
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Sub text
              const Text(
                "Login to your account",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // Username TextField
              TextField(
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Password TextField
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement login function
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF96E2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white, // 👈 WHITE text
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Forgot Password
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Forgot password
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Facebook and Google icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Facebook Icon
                  IconButton(
                    icon: const Icon(
                      Icons.facebook,
                      color: Colors.blue,
                      size: 30,
                    ),
                    onPressed: () {
                      // TODO: Facebook login
                    },
                  ),
                  const SizedBox(width: 20),
                  // Google Icon
                  Image.asset(
                    'assets/images/google_icon.png', // 👈 Add Google "G" icon manually
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Don't have account? Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Sign Up page
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
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
}
