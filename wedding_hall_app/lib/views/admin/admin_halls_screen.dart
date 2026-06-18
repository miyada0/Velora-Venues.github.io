import 'package:flutter/material.dart';
import 'package:wedding_hall_booking_app/models/hall_model.dart';
import 'package:wedding_hall_booking_app/services/admin_service.dart';
import 'package:wedding_hall_booking_app/theme/app_theme.dart';

class AdminHallsScreen extends StatefulWidget {
  const AdminHallsScreen({super.key});

  @override
  State<AdminHallsScreen> createState() => _AdminHallsScreenState();
}

class _AdminHallsScreenState extends State<AdminHallsScreen> {
  final AdminService adminService = AdminService();

  late Future<List<HallModel>> hallsFuture;
  String selectedFilter = "all"; // all, approved, pending, rejected

  @override
  void initState() {
    super.initState();
    hallsFuture = adminService.getAllHalls();
  }

  Future<void> _refreshHalls() async {
    setState(() {
      hallsFuture = adminService.getAllHalls();
    });
  }

  List<HallModel> _filterHalls(List<HallModel> halls) {
    if (selectedFilter == "all") {
      return halls;
    }
    return halls.where((hall) => hall.status == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Halls"),
        backgroundColor: AppTheme.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHalls,
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBg,
      body: FutureBuilder<List<HallModel>>(
        future: hallsFuture,
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
                    onPressed: _refreshHalls,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final allHalls = snapshot.data ?? [];
          final filteredHalls = _filterHalls(allHalls);

          return Column(
            children: [
              /// FILTER CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildFilterChip(
                      "All Halls (${allHalls.length})",
                      "all",
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      "Approved (${allHalls.where((h) => h.status == "approved").length})",
                      "approved",
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      "Pending (${allHalls.where((h) => h.status == "pending").length})",
                      "pending",
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      "Rejected (${allHalls.where((h) => h.status == "rejected").length})",
                      "rejected",
                    ),
                  ],
                ),
              ),

              /// HALLS LIST
              if (filteredHalls.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_center_outlined,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No halls found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredHalls.length,
                    itemBuilder: (context, index) {
                      final hall = filteredHalls[index];
                      return _buildHallCard(hall);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.gold.withOpacity(0.3),
      side: BorderSide(
        color: isSelected ? AppTheme.gold : Colors.grey[300]!,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.gold : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildHallCard(HallModel hall) {
    final statusColor = _getStatusColor(hall.status);
    final statusText = hall.status.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HALL IMAGE
          Stack(
            children: [
              if (hall.images.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    hall.images.first,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
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
                  height: 180,
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

              /// STATUS BADGE
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// HALL DETAILS
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HALL NAME & ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        hall.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                /// LOCATION
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hall.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                /// PRICE, CAPACITY, IMAGES COUNT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.money,
                        label: "₹${hall.price}",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.people,
                        label: "${hall.capacity} Capacity",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.image,
                        label: "${hall.images.length} Photos",
                      ),
                    ),
                  ],
                ),

                if (hall.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    hall.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                /// ✅ FIX #3: DELETE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(hall),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text("Delete Hall"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.gold),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.gold,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// ✅ FIX #3: Show delete confirmation dialog
  void _showDeleteConfirmation(HallModel hall) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Hall"),
        content: Text(
          "Are you sure you want to delete ${hall.name}? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHall(hall.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// ✅ FIX #3: Delete hall from database
  Future<void> _deleteHall(String hallId) async {
    try {
      await adminService.deleteHall(hallId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Hall deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ FIX #8: Refresh the list after delete
        _refreshHalls();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("❌ Error: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
