import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
//import 'admin_bookings_screen.dart';
import 'admin_halls_screen.dart';
import 'admin_users_screen.dart';
import 'pending_halls_screen.dart';

class ModernAdminDashboard extends ConsumerStatefulWidget {
  const ModernAdminDashboard({super.key});

  @override
  ConsumerState<ModernAdminDashboard> createState() =>
      _ModernAdminDashboardState();
}

class _ModernAdminDashboardState extends ConsumerState<ModernAdminDashboard> {
  int _currentNavIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              children: [
                // ========== GRADIENT HEADER WITH CURVE ==========
                _buildGradientHeader(),

                // ========== MAIN CONTENT ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ========== TOP ACTION CARD ==========
                      _buildTopActionCard(),

                      const SizedBox(height: 24),

                      // ========== DATE / STATUS CARD ==========
                      _buildDateStatusCard(),

                      const SizedBox(height: 24),

                      // ========== ANALYTICS SECTION (3 Circular Progress) ==========
                      _buildAnalyticsSection(),

                      const SizedBox(height: 24),

                      // ========== FEATURE GRID (2x3) ==========
                      _buildFeatureGrid(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ========== BOTTOM NAVIGATION BAR ==========
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  // ========== GRADIENT HEADER WITH CURVE ==========
  Widget _buildGradientHeader() {
    return ClipPath(
      clipper: _CurvedClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // Deep blue
              Color(0xFF5B21B6), // Deep purple/indigo
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== HEADER TOP ROW ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: App name/logo
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Velora Admin",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // Right: Icons for notifications, messages, profile
                  Row(
                    children: [
                      // Notifications
                      _buildHeaderIconButton(
                        icon: Icons.notifications_outlined,
                        badgeCount: 3,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("3 new notifications")),
                          );
                        },
                      ),

                      const SizedBox(width: 12),

                      // Messages
                      _buildHeaderIconButton(
                        icon: Icons.mail_outlined,
                        badgeCount: 2,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("2 new messages")),
                          );
                        },
                      ),

                      const SizedBox(width: 12),

                      // Profile
                      _buildHeaderIconButton(
                        icon: Icons.account_circle_outlined,
                        badgeCount: 0,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile settings")),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header icon button with badge
  Widget _buildHeaderIconButton({
    required IconData icon,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF6B6B),
                ),
                child: Center(
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========== TOP ACTION CARD ==========
  Widget _buildTopActionCard() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("System check completed!")),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Icon + Text
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF5B21B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.settings_suggest,
                color: Color(0xFF5B21B6),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "System Status",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Run system diagnostics",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Right: CTA Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF5B21B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Check",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DATE / STATUS CARD ==========
  Widget _buildDateStatusCard() {
    final dayName = DateFormat('EEEE').format(_selectedDate);
    final fullDate = DateFormat('MMMM dd, yyyy').format(_selectedDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date with navigation arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDate.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$dayName, $fullDate",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate =
                            _selectedDate.add(const Duration(days: 1));
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B21B6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF5B21B6),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate =
                            _selectedDate.subtract(const Duration(days: 1));
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B21B6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF5B21B6),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly status indicators
          const Text(
            "Weekly Status",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (index) {
              final isActive = index < 5;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index != 6 ? 8 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ========== ANALYTICS SECTION (3 Circular Progress) ==========
  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Analytics Overview",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCircularStatCard(
                label: "Total Bookings",
                value: 245,
                maxValue: 500,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCircularStatCard(
                label: "Revenue",
                value: 7850,
                maxValue: 10000,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCircularStatCard(
                label: "Active Users",
                value: 156,
                maxValue: 200,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Circular stat card
  Widget _buildCircularStatCard({
    required String label,
    required int value,
    required int maxValue,
    required Color color,
  }) {
    final percentage = (value / maxValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Progress
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                ),

                // Animated circular progress indicator
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percentage),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, animationValue, child) {
                    return CustomPaint(
                      size: const Size(80, 80),
                      painter: _CircleProgressPainter(
                        percentage: animationValue,
                        color: color,
                        strokeWidth: 6,
                      ),
                      child: child,
                    );
                  },
                  child: Center(
                    child: Text(
                      "${(percentage * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Value and label
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ========== FEATURE GRID (2 rows × 3 columns) ==========
  Widget _buildFeatureGrid() {
    final features = [
      {
        'icon': Icons.business,
        'label': 'Manage Halls',
        'color': const Color(0xFF3B82F6),
        'screen': const AdminHallsScreen(),
      },
      {
        'icon': Icons.pending_actions,
        'label': 'Approvals',
        'color': const Color(0xFFF59E0B),
        'screen': const PendingHallsScreen(),
      },
      {
        'icon': Icons.people,
        'label': 'Users',
        'color': const Color(0xFF10B981),
        'screen': const AdminUsersScreen(),
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Reports',
        'color': const Color(0xFF8B5CF6),
        'screen': const Scaffold(),
      },
      {
        'icon': Icons.notifications,
        'label': 'Notifications',
        'color': const Color(0xFFEC4899),
        'screen': const Scaffold(),
      },
      {
        'icon': Icons.settings,
        'label': 'Settings',
        'color': const Color(0xFF6B7280),
        'screen': const Scaffold(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureItem(
          icon: feature['icon'] as IconData,
          label: feature['label'] as String,
          color: feature['color'] as Color,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Opening ${feature['label']}..."),
                duration: const Duration(milliseconds: 500),
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => feature['screen'] as Widget),
            );
          },
        );
      },
    );
  }

  // Feature grid item
  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ScaleTransition(
        scale: Tween(begin: 0.98, end: 1.0).animate(
          CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.elasticOut),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular icon background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),

              // Label
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== BOTTOM NAVIGATION BAR ==========
  Widget _buildBottomNavBar() {
    final navItems = [
      {'icon': Icons.home, 'label': 'Dashboard'},
      {'icon': Icons.analytics, 'label': 'Analytics'},
      {'icon': Icons.task_alt, 'label': 'Tasks'},
      {'icon': Icons.mail, 'label': 'Messages'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(navItems.length, (index) {
            final isActive = _currentNavIndex == index;
            return InkWell(
              onTap: () {
                setState(() => _currentNavIndex = index);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      navItems[index]['icon'] as IconData,
                      color: isActive
                          ? const Color(0xFF5B21B6)
                          : AppTheme.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      navItems[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive
                            ? const Color(0xFF5B21B6)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ========== CUSTOM CLIPPER FOR CURVED HEADER ==========
class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ========== CUSTOM PAINTER FOR CIRCULAR PROGRESS ==========
class _CircleProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.withOpacity(0.1)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    // Progress circle
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      (2 * 3.14) * percentage,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => true;
}
