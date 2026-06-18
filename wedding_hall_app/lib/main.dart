import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
//import 'viewmodels/auth_vm.dart';
import 'models/booking_model.dart';
import 'services/notification_service.dart';

import 'views/navigation/main_navigation_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';
import 'views/admin/admin_analytics_screen.dart';

// 🔥 ADD THESE IMPORTS
import 'views/auth/login_screen.dart';
import 'views/owner/add_hall_screen.dart';
import 'views/owner/owner_dashboard_screen.dart';
import 'views/owner/my_halls_screen.dart';
import 'views/owner/hall_stats_screen.dart';
import 'views/booking/booking_details_screen.dart';
import 'views/profile/edit_profile_screen.dart';
import 'views/legal/terms_screen.dart';
import 'views/legal/privacy_screen.dart';
import 'views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ FIX #7: Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ FIX #7: Initialize Firebase Cloud Messaging
  await NotificationService().initializeFirebaseMessaging();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final auth = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      /// 🔥 ROUTES (IMPORTANT)
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainNavigationScreen(),
        '/admin-dashboard': (_) => const AdminDashboardScreen(),
        '/admin-analytics': (_) => const AdminAnalyticsScreen(),
        '/add-hall': (_) => const AddHallScreen(),
        '/register-hall': (_) => const AddHallScreen(),
        '/my-halls': (_) =>
            const MyHallsScreen(), // ✅ FIX #2: Add route for owner's halls
        '/owner-dashboard': (_) => const OwnerDashboardScreen(),
        '/edit-profile': (_) => const EditProfileScreen(),
        '/terms': (_) => const TermsScreen(),
        '/privacy': (_) => const PrivacyScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes with arguments
        if (settings.name == '/hall-stats') {
          final hallId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => HallStatsScreen(hallId: hallId ?? ''),
          );
        }
        if (settings.name == '/booking-details') {
          final booking = settings.arguments as BookingModel?;
          if (booking != null) {
            return MaterialPageRoute(
              builder: (_) => BookingDetailsScreen(booking: booking),
            );
          }
        }
        return null;
      },

      builder: (context, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },

      // ✅ FIX: ALWAYS start with login screen
      // No auto-login, no role-based redirection
      home: const SplashScreen(),
    );
  }
}
