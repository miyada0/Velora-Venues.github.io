import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_vm.dart';

/// Global error handler for API responses
class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      // Handle 401 Unauthorized
      if (error.response?.statusCode == 401) {
        return "Your session has expired. Please login again.";
      }

      // Handle 403 Forbidden
      if (error.response?.statusCode == 403) {
        return "You don't have permission to perform this action.";
      }

      // Handle 404 Not Found
      if (error.response?.statusCode == 404) {
        return "Resource not found.";
      }

      // Handle 400 Bad Request
      if (error.response?.statusCode == 400) {
        final message = error.response?.data["message"] ??
            error.response?.data["error"] ??
            "Invalid request. Please check your input.";
        return message;
      }

      // Handle 500+ Server Error
      if ((error.response?.statusCode ?? 0) >= 500) {
        return "Server error. Please try again later.";
      }

      // Handle network errors
      if (error.type == DioExceptionType.connectionTimeout) {
        return "Connection timeout. Please check your internet.";
      }
      if (error.type == DioExceptionType.receiveTimeout) {
        return "Request timeout. Please try again.";
      }
      if (error.type == DioExceptionType.unknown) {
        return "Network error. Please check your connection.";
      }

      return error.message ?? "Something went wrong";
    }

    return error.toString();
  }

  /// Handle 401 error: Logout user and navigate to login
  static Future<void> handle401(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Logout user
      await ref.read(authProvider.notifier).logout();

      // Navigate to login
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error handling 401: $e");
    }
  }

  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade600,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
