import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/hall_model.dart';
import '../../services/owner_service.dart';
import '../../theme/app_theme.dart';

class ManageHallScreen extends ConsumerStatefulWidget {
  final String? hallId;

  const ManageHallScreen({super.key, this.hallId});

  @override
  ConsumerState<ManageHallScreen> createState() => _ManageHallScreenState();
}

class _ManageHallScreenState extends ConsumerState<ManageHallScreen> {
  final OwnerService ownerService = OwnerService();

  HallModel? hall;
  bool loading = true;
  String? errorMessage;

  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController capacityController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    locationController = TextEditingController();
    priceController = TextEditingController();
    descriptionController = TextEditingController();
    capacityController = TextEditingController();
    loadHall();
  }

  Future<void> loadHall() async {
    try {
      final data = widget.hallId != null
          ? await ownerService.getHallById(widget.hallId!)
          : await ownerService.getMyHalls().then((halls) {
              if (halls.isEmpty) throw Exception("No halls found");
              return halls.first;
            });

      setState(() {
        hall = data;
        loading = false;

        if (hall != null) {
          nameController.text = hall!.name;
          locationController.text = hall!.location;
          priceController.text = hall!.price.toString();
          descriptionController.text = hall!.description;
          capacityController.text = hall!.capacity.toString();
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _updateHall() async {
    if (hall == null) return;

    try {
      await ownerService.updateHall(
        hall!.id,
        {
          "name": nameController.text,
          "location": locationController.text,
          "price": double.parse(priceController.text),
          "description": descriptionController.text,
          "capacity": int.parse(capacityController.text),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hall Updated Successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );

      // Reload hall data
      loadHall();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteHall() async {
    if (hall == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Hall?"),
        content: const Text(
          "Are you sure you want to permanently delete this hall? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ownerService.deleteHall(hall!.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hall Deleted Successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Manage Hall")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text("Error: $errorMessage"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadHall,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (hall == null) {
      return const Scaffold(
        body: Center(child: Text("No hall found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage My Hall"),
        backgroundColor: AppTheme.gold,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.lightBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hall Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(hall!.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(hall!.status),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(hall!.status),
                    color: _getStatusColor(hall!.status),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hall Status",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        hall!.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(hall!.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hall Image
            if (hall!.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hall!.images.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Form Fields
            Text(
              "Hall Details",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            /// Hall Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Hall Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 12),

            /// Location
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),

            /// Price
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: "Price (₹)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            /// Capacity
            TextField(
              controller: capacityController,
              decoration: InputDecoration(
                labelText: "Capacity (guests)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            /// Description
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _updateHall,
                icon: const Icon(Icons.update),
                label: const Text("Update Hall"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Delete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _deleteHall,
                icon: const Icon(Icons.delete),
                label: const Text("Delete Hall"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Icons.check_circle;
      case "pending":
        return Icons.schedule;
      case "rejected":
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
