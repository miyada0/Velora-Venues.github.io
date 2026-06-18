import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/auth_vm.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Validate form inputs
  bool _validateForm() {
    setState(() => errorMessage = null);

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      setState(() => errorMessage = "Please enter your name");
      return false;
    }

    if (email.isEmpty) {
      setState(() => errorMessage = "Please enter an email");
      return false;
    }

    if (!email.contains("@")) {
      setState(() => errorMessage = "Please enter a valid email");
      return false;
    }

    if (password.isEmpty) {
      setState(() => errorMessage = "Please enter a password");
      return false;
    }

    if (password.length < 6) {
      setState(() => errorMessage = "Password must be at least 6 characters");
      return false;
    }

    return true;
  }

  /// Handle signup
  Future<void> _handleSignup() async {
    if (!_validateForm()) return;

    setState(() => isLoading = true);

    try {
      print("\n🔐 SIGNUP SCREEN: Attempting signup");
      print("  👤 Name: ${nameController.text}");
      print("  📧 Email: ${emailController.text}");

      final success = await ref.read(authProvider.notifier).signup(
            nameController.text.trim(),
            emailController.text.trim(),
            passwordController.text.trim(),
            role: "user",
          );

      if (!success) {
        setState(() => errorMessage =
            "Signup failed. Please try again or use different credentials.");
        setState(() => isLoading = false);
        return;
      }

      print("  ✅ SIGNUP SUCCESSFUL");

      // ✅ Get the updated auth state
      final authState = ref.read(authProvider);
      final role = authState?["user"]?["role"] ?? "user";
      final email = authState?["user"]?["email"];

      print("    📧 Email: $email");
      print("    👥 Assigned Role: $role");

      // ✅ FIX: Wait for state to propagate before navigating
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      // ✅ FIX: ALL users go to the same HomePage (no role-based redirection)
      print("  📲 Navigating to home for all users");
      Navigator.of(context).pushNamedAndRemoveUntil(
        "/home",
        (route) => false,
      );
    } catch (e) {
      print("  ❌ Signup exception: $e");
      if (mounted) {
        setState(() => errorMessage = "Error: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
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

              /// NAME FIELD
              TextField(
                controller: nameController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  hintText: "Enter your full name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

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
                  hintText: "At least 6 characters",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              /// SIGNUP BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSignup,
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
                          "Create Account",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              /// LOGIN LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      "Login",
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
