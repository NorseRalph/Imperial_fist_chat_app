import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .white, // You can set the background color to match your branding
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // I can repace this with my logo
            CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Checking authentication...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Set a suitable color for the text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
