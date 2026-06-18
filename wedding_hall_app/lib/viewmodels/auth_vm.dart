import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

final authProvider =
    StateNotifierProvider<AuthVM, Map<String, dynamic>?>((ref) {
  return AuthVM();
});

class AuthVM extends StateNotifier<Map<String, dynamic>?> {
  AuthVM() : super(null) {
    _initAsync();
  }

  final AuthService _authService = AuthService();

  /// ✅ FIX: Track if we're currently logging out to prevent loops
  bool _isLoggingOut = false;

  /// 🔥 Initialize auth on app startup
  /// ✅ FIX: NO auto-login - app should start fresh without loading old tokens
  Future<void> _initAsync() async {
    try {
      print("🔄 AuthVM: Initializing...");

      // ✅ FIX: CLEAR any old token - always start fresh
      print("  📋 Clearing old token...");
      await _authService.logout();
      print("  ✅ Old token cleared - fresh start");

      // Register logout callback for 401 errors
      ApiService.setOnLogoutCallback(_performLogout);
      print("✅ AuthVM: Initialization complete - user must login");
    } catch (e) {
      print("❌ AuthVM: Error during init: $e");
    }
  }

  /// ✅ FIX: Internal logout method that's called by API service
  Future<void> _performLogout() async {
    if (_isLoggingOut) {
      print("⚠️ Logout already in progress");
      return;
    }

    try {
      _isLoggingOut = true;
      print("🔓 AuthVM: Automatic logout triggered by 401 response");
      state = null;
      await _authService.logout();
      print("✅ AuthVM: Auto-logout successful");
    } finally {
      _isLoggingOut = false;
    }
  }

  String get userId => state?["user"]?["_id"] ?? "";

  /// ✅ GET USER ROLE (admin, owner, user)
  String get userRole => state?["user"]?["role"] ?? "user";

  /// LOGIN
  Future<bool> login(String email, String password) async {
    try {
      final data = await _authService.login(email, password);

      print("\n📋 AUTH VM LOGIN DEBUG:");
      print("  ✅ Login successful");
      print("  📧 Email: ${data["user"]?["email"]}");
      print("  👤 Role: ${data["user"]?["role"]}");
      print("  🔐 Token: ${data["token"]?.substring(0, 20)}...");

      state = data; // contains token + user

      print("  ✅ Auth state updated");
      print("  UserRole getter returns: $userRole");

      return true;
    } catch (e) {
      print("\n❌ AUTH VM LOGIN ERROR: $e");
      return false;
    }
  }

  /// SIGNUP
  Future<bool> signup(String name, String email, String password,
      {required String role}) async {
    try {
      final data = await _authService.signup(name, email, password);

      state = data;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// LOGOUT - ✅ FIX: Prevent multiple logouts
  Future<void> logout() async {
    await _performLogout();
  }
}
