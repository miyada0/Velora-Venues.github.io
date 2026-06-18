import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService api = ApiService();
  static const String _tokenKey = 'auth_token';

  /* ================ RESTORE TOKEN ON APP START ================ */
  /// Called on app startup to restore session from device storage
  Future<void> restoreToken() async {
    try {
      print("\n🔄 RESTORING TOKEN FROM STORAGE...");

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null && token.trim().isNotEmpty) {
        print("  ✅ Token found in storage");
        // ✅ FIX: Use async setToken to ensure it's properly set in Dio
        await api.setToken(token);
        print("  ✅ Token restored and set in API headers");
      } else {
        print("  ⚠️  No token found in storage - user needs to login");
      }
    } catch (e) {
      print("  ❌ Error restoring token: $e");
      // Don't rethrow - this is just initialization
    }
  }

  /* ================ LOGIN ================ */
  /// Authenticates user with email and password
  /// Returns user data + token on success
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print("\n🔄 LOGIN REQUEST:");
      print("  📧 Email: $email");

      if (email.isEmpty || password.isEmpty) {
        throw Exception("Email and password are required");
      }

      final res = await api.dio.post(
        "/auth/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      print("  ✅ LOGIN SUCCESSFUL");
      print("  📦 Response Status: ${res.statusCode}");
      print("  Token: ${res.data["token"]?.substring(0, 20)}...");
      print("  User: ${res.data["user"]}");
      print("  Role: ${res.data["user"]?["role"]}");

      final token = res.data["token"];

      if (token == null || token.isEmpty) {
        throw Exception("Server returned empty token");
      }

      // ✅ CRITICAL: Set token AND wait for it to be persisted
      print("  🔐 Saving token to storage...");
      await api.setToken(token);

      print("  ✅ Token persisted successfully");

      // ✅ Small delay to ensure token is safely written before navigation
      await Future.delayed(const Duration(milliseconds: 300));

      return res.data;
    } catch (e) {
      print("  ❌ LOGIN ERROR: $e");
      rethrow;
    }
  }

  /* ================ SIGNUP ================ */
  /// Creates new user account with optional role
  /// Automatically logs in user after signup
  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password, {
    String role = "user",
  }) async {
    try {
      print("\n🔄 SIGNUP REQUEST:");
      print("  👤 Name: $name");
      print("  📧 Email: $email");
      print("  👥 Role: $role");

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception("Name, email, and password are required");
      }

      if (password.length < 6) {
        throw Exception("Password must be at least 6 characters");
      }

      final res = await api.dio.post(
        "/auth/signup",
        data: {
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        },
      );

      print("  ✅ SIGNUP SUCCESSFUL");
      print("  📦 Response Status: ${res.statusCode}");
      print("  Token: ${res.data["token"]?.substring(0, 20)}...");
      print("  User Role: ${res.data["user"]?["role"]}");

      final token = res.data["token"];

      if (token == null || token.isEmpty) {
        throw Exception("Server returned empty token");
      }

      // ✅ Auto login after signup - Set token
      print("  🔐 Saving token to storage...");
      await api.setToken(token);

      print("  ✅ Token persisted successfully");

      // ✅ Small delay to ensure token is safely persisted
      await Future.delayed(const Duration(milliseconds: 300));

      return res.data;
    } catch (e) {
      print("  ❌ SIGNUP ERROR: $e");
      rethrow;
    }
  }

  /* ================ GET PROFILE ================ */
  /// Fetches current user profile (requires auth token)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      print("\n📋 Fetching user profile...");
      final res = await api.dio.get("/auth/me");
      print("  ✅ Profile fetched");
      return res.data;
    } catch (e) {
      print("  ❌ GET PROFILE ERROR: $e");
      rethrow;
    }
  }

  /* ================ UPDATE PROFILE ================ */
  /// Updates user name and/or email
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      print("\n📝 Updating profile...");
      final res = await api.dio.put(
        "/auth/update-profile",
        data: {
          "name": name,
          "email": email,
        },
      );
      print("  ✅ Profile updated");
      return res.data;
    } catch (e) {
      print("  ❌ UPDATE PROFILE ERROR: $e");
      rethrow;
    }
  }

  /* ================ LOGOUT ================ */
  /// Clears authentication token and local user data
  Future<void> logout() async {
    try {
      print("\n🔓 LOGOUT:");
      await api.clearToken();
      print("  ✅ Logout successful - token cleared");
    } catch (e) {
      print("  ❌ LOGOUT ERROR: $e");
      rethrow;
    }
  }
}
