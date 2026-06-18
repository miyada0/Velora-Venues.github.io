//import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Callback function for handling logout (when token expires)
typedef OnLogoutCallback = Future<void> Function();

class ApiService {
  /// 🔥 SINGLETON INSTANCE
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  static Future<Map<String, dynamic>> createOrder(int amount) async {
    try {
      final response = await ApiService().dio.post(
        "/payment/create-order",
        data: {
          "amount": amount,
        },
      );

      return response.data;
    } catch (e) {
      throw Exception("Failed to create order: $e");
    }
  }

  ApiService._internal() {
    _init();
  }

  late final Dio dio;
  static const String _tokenKey = 'auth_token';

  /// ✅ FIX: Global logout callback - set by AuthVM
  static OnLogoutCallback? _onLogoutCallback;

  /// ✅ FIX: Flag to prevent multiple logout triggers
  static bool _isProcessingLogout = false;

  /// Set logout callback (called from AuthVM)
  static void setOnLogoutCallback(OnLogoutCallback callback) {
    _onLogoutCallback = callback;
  }

  /// ================= INIT =================
  void _init() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://172.28.183.20:5000/api",
        headers: {
          "Content-Type": "application/json",
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    /// 🔥 TOKEN INTERCEPTOR - Fetch token from storage before each request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint(
              "\n➡️  API REQUEST: ${options.method.toUpperCase()} ${options.path}");

          try {
            // ✅ FETCH TOKEN FROM STORAGE
            final token = await _getStoredToken();

            if (token != null && token.trim().isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
              debugPrint("  🔐 Token attached (${token.substring(0, 20)}...)");
            } else {
              debugPrint("  ⚠️  No token available for this request");
              // Don't fail - some endpoints don't need auth
            }
          } catch (e) {
            debugPrint("  ❌ Error attaching token: $e");
            // Continue without token rather than failing
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
              "  ✅ RESPONSE: ${response.statusCode} from ${response.requestOptions.path}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // ✅ FIX: Handle 401 errors only once, but NOT on auth endpoints
          final isAuthEndpoint =
              e.requestOptions.path.contains("/auth/login") ||
                  e.requestOptions.path.contains("/auth/signup") ||
                  e.requestOptions.path.contains("/auth/me");

          if (e.response?.statusCode == 401 && !isAuthEndpoint) {
            debugPrint("  🚨 401 UNAUTHORIZED on ${e.requestOptions.path}");
            _handleUnauthorized();
          }

          final errorMsg = e.response?.data ?? e.message ?? "Unknown error";
          debugPrint(
              "  ❌ ERROR ${e.response?.statusCode ?? 'TIMEOUT'}: $errorMsg");

          return handler.next(e);
        },
      ),
    );

    /// 🔄 RETRY INTERCEPTOR - Retry failed requests automatically (NOT on 401)
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logger: debugPrint,
      ),
    );
  }

  /// ✅ FIX: Handle unauthorized requests safely
  static Future<void> _handleUnauthorized() async {
    if (_isProcessingLogout) {
      debugPrint("  ⚠️  Logout is already processing, skipping duplicate");
      return;
    }

    _isProcessingLogout = true;
    try {
      if (_onLogoutCallback != null) {
        debugPrint("  🔐 Triggering automatic logout due to 401");
        await _onLogoutCallback!();
      } else {
        debugPrint(
            "  ⚠️  No logout callback set - token will be cleared by default");
      }
    } catch (e) {
      debugPrint("  ❌ Error during logout callback: $e");
    } finally {
      _isProcessingLogout = false;
    }
  }

  /// ================= TOKEN MANAGEMENT =================

  /// GET TOKEN FROM SHARED PREFERENCES - WITH SAFETY CHECKS
  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        debugPrint("    [TOKEN] No token in storage");
        return null;
      }

      if (token.isEmpty) {
        debugPrint("    [TOKEN] Token is empty");
        await clearToken();
        return null;
      }

      debugPrint("    [TOKEN] Token found (${token.length} chars)");
      return token;
    } catch (e) {
      debugPrint("    [TOKEN] Error fetching: $e");
      return null;
    }
  }

  /// SET TOKEN AFTER LOGIN - WITH PERSISTENCE CHECK
  Future<void> setToken(String token) async {
    debugPrint("\n🔐 SETTING TOKEN:");
    try {
      if (token.isEmpty) {
        debugPrint("  ❌ Cannot set empty token");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      dio.options.headers["Authorization"] = "Bearer $token";

      debugPrint("  ✅ Token persisted to SharedPreferences");
      debugPrint("  ✅ Token set in Dio headers");

      // Verify it was saved
      final saved = prefs.getString(_tokenKey);
      if (saved == token) {
        debugPrint("  ✅ Token persistence verified");
      } else {
        debugPrint("  ❌ Token persistence verification FAILED");
      }
    } catch (e) {
      debugPrint("  ❌ Error setting token: $e");
      rethrow;
    }
  }

  /// CLEAR TOKEN ON LOGOUT
  Future<void> clearToken() async {
    debugPrint("\n🔓 CLEARING TOKEN:");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      dio.options.headers.remove("Authorization");
      debugPrint("  ✅ Token cleared from storage and headers");
    } catch (e) {
      debugPrint("  ❌ Error clearing token: $e");
    }
  }

  /// GET CURRENT TOKEN (for debugging)
  Future<String?> getToken() async {
    return await _getStoredToken();
  }
}

/// =================== RETRY INTERCEPTOR ===================
/// Automatically retries failed requests up to 3 times
/// ✅ FIX: Does NOT retry on 401 or login/signup endpoints
class RetryInterceptor extends QueuedInterceptor {
  RetryInterceptor({
    required this.dio,
    required this.logger,
    this.maxRetries = 3,
  });

  final Dio dio;
  final Function(String)? logger;
  final int maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldRetry(err) && _hasRetries(err)) {
      _retry(err, handler);
    } else {
      super.onError(err, handler);
    }
  }

  Future<void> _retry(DioException err, ErrorInterceptorHandler handler) async {
    final retries = _getRetries(err);
    final options = err.requestOptions;

    logger?.call(
        '  🔄 Retrying request (Attempt ${retries + 1}/$maxRetries): ${options.path}');

    try {
      // Wait before retry (exponential backoff)
      await Future.delayed(Duration(milliseconds: 300 * (retries + 1)));

      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      if (_hasRetries(e)) {
        await _retry(e, handler);
      } else {
        logger?.call('  ❌ Max retries reached for ${e.requestOptions.path}');
        handler.next(e);
      }
    }
  }

  bool _shouldRetry(DioException err) {
    // ✅ FIX: Do NOT retry on 401
    if (err.response?.statusCode == 401) {
      return false;
    }

    // ✅ Do NOT retry on auth endpoints
    if (err.requestOptions.path.contains("/auth/login") ||
        err.requestOptions.path.contains("/auth/signup") ||
        err.requestOptions.path.contains("/auth/me")) {
      return false;
    }

    // Retry on timeout, network errors, and 5xx
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.unknown ||
        (err.response?.statusCode ?? 0) >= 500;
  }

  bool _hasRetries(DioException err) {
    final retries = _getRetries(err);
    return retries < maxRetries;
  }

  int _getRetries(DioException err) {
    final retries = err.requestOptions.extra['retries'] ?? 0;
    err.requestOptions.extra['retries'] = retries + 1;
    return retries;
  }
}
