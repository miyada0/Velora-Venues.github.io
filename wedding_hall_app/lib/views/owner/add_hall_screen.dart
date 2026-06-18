import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../services/safe_api.dart';
import '../../utils/error_handler.dart';

class AddHallScreen extends ConsumerStatefulWidget {
  const AddHallScreen({super.key});

  @override
  ConsumerState<AddHallScreen> createState() => _AddHallScreenState();
}

class _AddHallScreenState extends ConsumerState<AddHallScreen> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final capacityController = TextEditingController();
  final imageController = TextEditingController();
  final facilityController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> registerHall() async {
    // Validate inputs
    if (nameController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        imageController.text.trim().isEmpty) {
      ErrorHandler.showError(
        context,
        "Please fill in all required fields (Name, Location, Price, Images)",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      /// ✅ CONVERT STRINGS TO LIST
      final images = imageController.text
          .split(",")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final facilities = facilityController.text.isEmpty
          ? []
          : facilityController.text
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      if (images.isEmpty) {
        ErrorHandler.showError(
            context, "Please provide at least one image URL");
        setState(() => isLoading = false);
        return;
      }

      /// ✅ API CALL with proper error handling
      await ApiService().dio.post(
        "/halls",
        data: {
          "name": nameController.text.trim(),
          "location": locationController.text.trim(),
          "price": int.tryParse(priceController.text) ?? 0,
          "capacity": int.tryParse(capacityController.text) ?? 100,
          "images": images, // ✅ Array format
          "facilities": facilities,
          "description": descriptionController.text.trim(),
        },
      );

      if (!mounted) return;

      ErrorHandler.showSuccess(
        context,
        "Hall registered successfully! 🎉 Pending admin approval.",
      );

      // Clear form
      nameController.clear();
      locationController.clear();
      priceController.clear();
      capacityController.clear();
      imageController.clear();
      facilityController.clear();
      descriptionController.clear();

      // Navigate back
      Future.delayed(
        const Duration(milliseconds: 1500),
        () {
          if (mounted) Navigator.pop(context);
        },
      );
    } catch (e) {
      if (!mounted) return;

      // ✅ FIX: Check if 401 Unauthorized
      bool is401 = false;
      if (e is DioException) {
        is401 = e.response?.statusCode == 401;
      }

      if (is401) {
        SafeApi.handle401(context, ref);
      } else {
        // ✅ FIX: Show actual backend error message
        final errorMessage = ErrorHandler.getMessage(e);
        print("REGISTER ERROR: $e");
        print("Error message: $errorMessage");

        ErrorHandler.showError(context, errorMessage);
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    priceController.dispose();
    capacityController.dispose();
    imageController.dispose();
    facilityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          hintText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFEC407A),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Your Hall"),
        backgroundColor: const Color(0xFFEC407A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            inputField("Hall Name", nameController, required: true),
            inputField("Location", locationController, required: true),
            inputField("Price per Day", priceController,
                type: TextInputType.number, required: true),
            inputField("Capacity", capacityController,
                type: TextInputType.number, required: false),
            inputField(
              "Image URLs (comma separated)",
              imageController,
              required: true,
              maxLines: 3,
            ),
            inputField(
              "Facilities (comma separated)",
              facilityController,
              maxLines: 2,
            ),
            inputField(
              "Description",
              descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : registerHall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC407A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        "Register Hall",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Note: Your hall will be pending admin approval before appearing on the platform.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
