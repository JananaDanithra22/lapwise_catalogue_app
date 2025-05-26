import 'package:flutter/material.dart';

class DynamicButtonStyle extends StatelessWidget {
  final String buttonTitle;
  final VoidCallback onPressed;

  const DynamicButtonStyle({
    super.key,
    required this.buttonTitle,
    required this.onPressed,
  });

  static const Color defaultOrange = Color(0xFFFFB444);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: defaultOrange,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        foregroundColor: const Color.fromARGB(255, 9, 83, 153),
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(buttonTitle),
    );
  }
}

//use button
// DynamicButtonStyle(
//   buttonTitle: 'Click Me',
//   onPressed: () {
//     // Do something nice here
//     print('Button clicked!');
//   },
// ),

