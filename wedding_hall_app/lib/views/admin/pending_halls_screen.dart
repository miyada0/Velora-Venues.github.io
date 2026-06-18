import 'package:flutter/material.dart';
import 'package:wedding_hall_booking_app/models/hall_model.dart';
import 'package:wedding_hall_booking_app/services/admin_service.dart';
import 'package:wedding_hall_booking_app/theme/app_theme.dart';

class PendingHallsScreen extends StatefulWidget {
  const PendingHallsScreen({super.key});

  @override
  State<PendingHallsScreen> createState() => _PendingHallsScreenState();
}

class _PendingHallsScreenState extends State<PendingHallsScreen> {
  final AdminService adminService = AdminService();

  late Future<List<HallModel>> pendingHallsFuture;

  @override
  void initState() {
    super.initState();
    pendingHallsFuture = adminService.getPendingHalls();
  }

  Future<void> _approveHall(String hallId) async {
    try {
      await adminService.approveHall(hallId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hall approved successfully! ✅"),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the list
      setState(() {
        pendingHallsFuture = adminService.getPendingHalls();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error approving hall: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectHall(String hallId) async {
    try {
      await adminService.rejectHall(hallId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hall rejected successfully! ❌"),
          backgroundColor: Colors.orange,
        ),
      );

      // Refresh the list
      setState(() {
        pendingHallsFuture = adminService.getPendingHalls();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error rejecting hall: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Halls"),
        backgroundColor: AppTheme.gold,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.lightBg,
      body: FutureBuilder<List<HallModel>>(
        future: pendingHallsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 50, color: Colors.red.shade600),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        pendingHallsFuture = adminService.getPendingHalls();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final halls = snapshot.data ?? [];

          if (halls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 50,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "All halls approved!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No pending halls to review",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: halls.length,
            itemBuilder: (context, index) {
              final hall = halls[index];
              return _buildHallCard(hall);
            },
          );
        },
      ),
    );
  }

  Widget _buildHallCard(HallModel hall) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HALL IMAGE
          if (hall.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                hall.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 40),
              ),
            ),

          /// HALL DETAILS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HALL NAME
                Text(
                  hall.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                /// LOCATION
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hall.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// PRICE & CAPACITY
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailChip(
                        icon: Icons.money,
                        label: "₹${hall.price}/day",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailChip(
                        icon: Icons.people,
                        label: "${hall.capacity} Capacity",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// DESCRIPTION (if available)
                if (hall.description.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hall.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                /// OWNER INFO (if available)
                if (hall.ownerId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person,
                              size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Owner: ${hall.ownerId}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                /// ACTION BUTTONS
                Row(
                  children: [
                    /// REJECT BUTTON
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showConfirmationDialog(
                          context,
                          "Reject Hall",
                          "Are you sure you want to reject ${hall.name}?",
                          () => _rejectHall(hall.id),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text("Reject"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// APPROVE BUTTON
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showConfirmationDialog(
                          context,
                          "Approve Hall",
                          "Are you sure you want to approve ${hall.name}?",
                          () => _approveHall(hall.id),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text("Approve"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.gold),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.gold,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
