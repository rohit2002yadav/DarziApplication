import 'package:flutter/material.dart';

// The main function is the entry point of the Flutter application.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darzi Direct',
      theme: ThemeData(
        primarySwatch: Colors.purple, // Define a primary color for the app
      ),
      home: const WelcomeScreen(), // Set WelcomeScreen as the initial screen
      // Define named routes for navigation
      routes: {
        '/login': (context) => const Placeholder(), // Replace with your LoginScreen
        '/signup': (context) => const Placeholder(), // Replace with your SignupScreen
      },
      debugShowCheckedModeBanner: false, // Remove the debug banner
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Primary purple color used in your theme
    const Color primaryColor = Color(0xFF6A1B9A);

    return Scaffold(
      // Light purple background for the whole screen
      backgroundColor: const Color(0xFFF3E5F5),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .center, // Centers everything vertically on screen

            children: [
              // ---------------------------
              // 1. TOP IMAGE
              // ---------------------------
              Image.asset(
                'assets/images/unnamed.jpg', // Ensure this path is correct and the image exists
                height: 250,
                fit: BoxFit.contain,

                // If the image fails to load → show fallback text
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 250,
                    child: Center(child: Text('Image not found')),
                  );
                },
              ),

              const SizedBox(height: 30),

              // ---------------------------
              // 2. WELCOME TEXTS
              // ---------------------------

              const Text(
                'WELCOME TO',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  letterSpacing: 2, // spacing for “WELCOME TO”
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Darzi Direct',
                style: TextStyle(
                  color: primaryColor, // Custom purple color
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Tailored to your style, stitched to perfection — right at your doorstep.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              // ---------------------------
              // 3. LOGIN + SIGNUP BUTTONS
              // ---------------------------

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ----- LOGIN BUTTON -----
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      // When pressed → navigate to login screen
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        primaryColor, // Purple background for Login
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),

                      child: const Text(
                        'LOGIN',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // Added color for text
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ----- SIGNUP BUTTON -----
                  SizedBox(
                    width: 140,
                    child: OutlinedButton(
                      // When pressed → navigate to signup screen
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },

                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),

                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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