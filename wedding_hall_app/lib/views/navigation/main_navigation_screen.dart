import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../viewmodels/auth_vm.dart';
import '../home/home_screen.dart';
import '../booking/my_bookings_screen.dart';
import '../profile/profile_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final role = auth?["user"]?["role"] ?? "user";

    // ✅ FIX: Allow guests to browse (don't require authentication)
    // Guest users see HomeScreen with hall listings
    // Authenticated users see personalized content (bookings, wishlist, etc.)
    // Only actions like booking, adding to wishlist, or hall registration require login

    // ✅ ADMIN PAGES - ONLY DASHBOARD & PROFILE, NO ACCESS TO BOOKING/HALL SCREENS
    final adminPages = [
      const AdminDashboardScreen(),
      const ProfileScreen(),
    ];

    // ✅ OWNER PAGES - DASHBOARD & PROFILE, NO USER BROWSING
    final ownerPages = [
      const OwnerDashboardScreen(),
      const ProfileScreen(),
    ];

    // ✅ USER PAGES - HOME & BOOKINGS & PROFILE, NO ADMIN/OWNER SCREENS
    final userPages = [
      const HomeScreen(),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];

    // ✅ SELECT PAGES BASED ON ROLE
    late List<Widget> pages;
    late List<BottomNavigationBarItem> navigationItems;

    if (role == "admin") {
      pages = adminPages;
      navigationItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ];
    } else if (role == "owner") {
      pages = ownerPages;
      navigationItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: "My Halls",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ];
    } else {
      pages = userPages;
      navigationItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Bookings",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ];
    }

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: navigationItems,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}
