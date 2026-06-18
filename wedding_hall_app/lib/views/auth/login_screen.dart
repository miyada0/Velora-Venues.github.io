import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding_hall_booking_app/views/auth/signup_screen.dart';

import '../../viewmodels/auth_vm.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Validate login inputs
  bool _validateInputs() {
    setState(() => errorMessage = null);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => errorMessage = "Please enter your email");
      return false;
    }

    if (!email.contains("@")) {
      setState(() => errorMessage = "Please enter a valid email");
      return false;
    }

    if (password.isEmpty) {
      setState(() => errorMessage = "Please enter your password");
      return false;
    }

    return true;
  }

  /// Handle login
  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    try {
      print("\n🔐 LOGIN SCREEN: Attempting login");
      print("  📧 Email: ${emailController.text}");

      final success = await ref.read(authProvider.notifier).login(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

      if (!mounted) return;

      if (!success) {
        setState(() =>
            errorMessage = "Invalid email or password. Please try again.");
        setState(() => isLoading = false);
        return;
      }

      // ✅ Get user role from updated state
      final authState = ref.read(authProvider);
      final role = authState?["user"]?["role"] ?? "user";
      final userId = authState?["user"]?["_id"];
      final email = authState?["user"]?["email"];

      print("  ✅ LOGIN SUCCESSFUL");
      print("    📧 Email: $email");
      print("    👥 Role: $role");
      print("    🆔 UserID: $userId");

      // ✅ FIX: Wait a moment for state to be fully updated before navigating
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      // ✅ FIX: ALL users go to the same HomePage (no role-based redirection)
      print("  📲 Navigating to home for all users");
      Navigator.of(context).pushNamedAndRemoveUntil(
        "/home",
        (route) => false,
      );
    } catch (e) {
      print("  ❌ Login exception: $e");
      if (mounted) {
        setState(() => errorMessage = "Error: ${e.toString()}");
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo or branding
              Icon(
                Icons.celebration,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              const Text(
                "Wedding Hall Booking",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 40),

              // Error message
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              /// EMAIL FIELD
              TextField(
                controller: emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              /// PASSWORD FIELD
              TextField(
                controller: passwordController,
                enabled: !isLoading,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              const SizedBox(height: 20),

              /// SIGNUP LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignupScreen()),
                            );
                          },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
