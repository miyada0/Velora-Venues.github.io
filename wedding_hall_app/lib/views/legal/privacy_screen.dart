import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            """
We respect your privacy.

• We collect name, email and booking details.
• Passwords are securely hashed.
• We do not share personal data with third parties.
• Data is stored securely in MongoDB database.

For support contact: support@weddingapp.com
            """,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
