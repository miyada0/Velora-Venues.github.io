import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/auth_vm.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // ✅ FIX: Check if user is authenticated
    // If authenticated, show home. If not, show welcome screen with login option
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth != null && auth.containsKey("user")) {
        // ✅ User is authenticated - navigate to home
        print("✅ SPLASH: User authenticated, navigating to home");
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/wedding_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Plan your",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const Text(
                  "Perfect Wedding 💍",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                // ✅ FIX: If user is authenticated, show "Continue" button
                // Otherwise show "Login" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // ✅ FIX: ALL users (authenticated or not) should go to home
                      // Guest users can browse halls without login
                      // Authenticated users see their logged-in content
                      print(
                          "📲 SPLASH: Navigating to home (guest or authenticated)");
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text(
                      "Explore App",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
