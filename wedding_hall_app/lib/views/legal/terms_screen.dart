import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            """
Welcome to Wedding Hall Booking App.

1. Users must provide accurate booking details.
2. Advance payments are non-refundable.
3. Cancellation is allowed but advance is not refunded.
4. The platform is not responsible for disputes between users and hall owners.
5. Hall availability depends on confirmed bookings only.

By using this app, you agree to our policies.
            """,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
