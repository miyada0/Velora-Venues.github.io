import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:wedding_hall_booking_app/models/admin_stats_model.dart';
import 'package:wedding_hall_booking_app/services/admin_service.dart';
import 'package:wedding_hall_booking_app/services/safe_api.dart';
import 'package:wedding_hall_booking_app/theme/app_theme.dart';
//import '../../viewmodels/auth_vm.dart';
import 'admin_bookings_screen.dart';
import 'admin_halls_screen.dart';
import 'admin_users_screen.dart';
import 'pending_halls_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final AdminService adminService = AdminService();

  late Future<AdminStatsModel> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = adminService.getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: FutureBuilder<AdminStatsModel>(
        future: statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // ✅ FIX: Check if 401 Unauthorized
            bool is401 = false;
            if (snapshot.error is DioException) {
              is401 =
                  (snapshot.error as DioException).response?.statusCode == 401;
            }

            if (is401) {
              // Schedule async operation after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SafeApi.handle401(context, ref);
              });
              return const SizedBox.shrink();
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 50, color: Colors.red.shade600),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        statsFuture = adminService.getStats();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                    ),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ WELCOME HEADER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.gold, AppTheme.gold.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Admin 👑",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Manage your platform efficiently",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ✅ STATS SECTION TITLE
                const Text(
                  "Platform Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ STATS GRID (2 COLUMNS)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    _buildStatGridCard(
                      icon: Icons.people,
                      title: "Users",
                      value: stats.totalUsers.toString(),
                      color: Colors.blue,
                    ),
                    _buildStatGridCard(
                      icon: Icons.home,
                      title: "Halls",
                      value: stats.totalHalls.toString(),
                      color: Colors.green,
                    ),
                    _buildStatGridCard(
                      icon: Icons.calendar_today,
                      title: "Bookings",
                      value: stats.totalBookings.toString(),
                      color: Colors.orange,
                    ),
                    _buildStatGridCard(
                      icon: Icons.trending_up,
                      title: "Revenue",
                      value: "₹${stats.totalRevenue.toStringAsFixed(0)}",
                      color: AppTheme.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ✅ MANAGEMENT SECTION TITLE
                const Text(
                  "Management",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ MANAGEMENT GRID (2 COLUMNS)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    _buildManagementCard(
                      icon: Icons.pending_actions,
                      title: "Pending\nHalls",
                      color: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PendingHallsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildManagementCard(
                      icon: Icons.business,
                      title: "All\nHalls",
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminHallsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildManagementCard(
                      icon: Icons.group,
                      title: "Manage\nUsers",
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminUsersScreen(),
                          ),
                        );
                      },
                    ),
                    _buildManagementCard(
                      icon: Icons.book_online,
                      title: "All\nBookings",
                      color: Colors.deepOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminBookingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildManagementCard(
                      icon: Icons.analytics,
                      title: "Analytics",
                      color: AppTheme.gold,
                      onTap: () {
                        Navigator.pushNamed(context, '/admin-analytics');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ STAT GRID CARD (For overview stats)
  Widget _buildStatGridCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ MANAGEMENT CARD (For management tools)
  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
