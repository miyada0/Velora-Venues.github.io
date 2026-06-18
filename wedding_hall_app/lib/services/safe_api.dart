import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_vm.dart';

/// Safe API call wrapper - Handles 401 & errors globally
class SafeApi {
  /// ✅ FIX: Track logout state to prevent loops
  static bool _isHandlingLogout = false;

  /// Execute API call with safe error handling
  /// On 401: Auto-logout + navigate to login
  /// On other errors: Show snackbar
  static Future<T?> call<T>(
    Future<T> Function() apiCall, {
    required BuildContext context,
    required WidgetRef ref,
    String? onErrorMessage,
  }) async {
    try {
      return await apiCall();
    } catch (e) {
      if (context.mounted) {
        _handleError(e, context, ref, onErrorMessage);
      }
      return null;
    }
  }

  /// Handle errors and show appropriate UI
  static void _handleError(
    dynamic error,
    BuildContext context,
    WidgetRef ref,
    String? customMessage,
  ) {
    String errorMessage = customMessage ?? "Something went wrong";

    if (error is DioException) {
      // ✅ HANDLE 401 - Session expired (but prevent loops)
      if (error.response?.statusCode == 401) {
        // Only handle 401 if:
        // 1. Token exists (not already logged out)
        // 2. We're not already handling a logout
        final authState = ref.read(authProvider);
        if (authState != null && !_isHandlingLogout) {
          handle401(context, ref);
          return;
        } else if (authState == null) {
          errorMessage = "Please login to continue";
        } else {
          debugPrint("⚠️ 401 already being handled, skipping duplicate");
          return;
        }
      }
      // Handle 403 - Forbidden
      else if (error.response?.statusCode == 403) {
        errorMessage = "You don't have permission for this action";
      }
      // Handle 404 - Not found
      else if (error.response?.statusCode == 404) {
        errorMessage = "Resource not found";
      }
      // Handle 400 - Bad request
      else if (error.response?.statusCode == 400) {
        errorMessage = error.response?.data["error"] ??
            error.response?.data["message"] ??
            "Invalid request";
      }
      // Handle 500+ - Server error
      else if ((error.response?.statusCode ?? 0) >= 500) {
        errorMessage = "Server error. Please try again later";
      }
      // Handle network errors
      else if (error.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout. Check your internet";
      } else if (error.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Request timeout. Try again";
      } else if (error.type == DioExceptionType.unknown) {
        errorMessage = "Network error. Check your connection";
      } else {
        errorMessage = error.message ?? "API Error";
      }
    }

    // Show error snackbar
    _showSnackbar(context, errorMessage, isError: true);
  }

  /// Handle 401 - Logout & navigate to login
  /// ✅ FIX: Prevent multiple simultaneous logouts
  static Future<void> handle401(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (_isHandlingLogout) {
      print("⚠️ Already handling logout, skipping");
      return;
    }

    try {
      _isHandlingLogout = true;
      print("🚨 401 UNAUTHORIZED - Session expired");

      // Logout
      await ref.read(authProvider.notifier).logout();

      if (context.mounted) {
        // Show message
        _showSnackbar(
          context,
          "Session expired. Please login again",
          isError: true,
        );

        // Navigate to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      print("❌ Error during logout: $e");
    } finally {
      _isHandlingLogout = false;
    }
  }

  /// Show SUCCESS snackbar
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, isError: false);
  }

  /// Show ERROR snackbar
  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, isError: true);
  }

  /// Common snackbar UI
  static void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
