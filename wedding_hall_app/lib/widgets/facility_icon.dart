import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Facility Icon Widget - Display hall facilities with icons
class FacilityIcon extends StatelessWidget {
  final String facilityName;
  final IconData icon;

  const FacilityIcon({
    super.key,
    required this.facilityName,
    this.icon = Icons.check_circle,
  });

  /// Get icon based on facility name
  static IconData getIconForFacility(String facility) {
    final name = facility.toLowerCase();

    if (name.contains('wifi') || name.contains('internet')) {
      return Icons.wifi;
    } else if (name.contains('dining') ||
        name.contains('food') ||
        name.contains('catering')) {
      return Icons.restaurant;
    } else if (name.contains('decoration') || name.contains('decor')) {
      return Icons.style;
    } else if (name.contains('parking')) {
      return Icons.local_parking;
    } else if (name.contains('ac') || name.contains('cooling')) {
      return Icons.ac_unit;
    } else if (name.contains('video') || name.contains('record')) {
      return Icons.videocam;
    } else if (name.contains('ground') || name.contains('outdoor')) {
      return Icons.landscape;
    } else if (name.contains('light') || name.contains('lighting')) {
      return Icons.light_mode;
    } else if (name.contains('sound') || name.contains('audio')) {
      return Icons.surround_sound;
    } else if (name.contains('stage')) {
      return Icons.apartment;
    } else if (name.contains('kitchen')) {
      return Icons.kitchen;
    } else if (name.contains('photography')) {
      return Icons.photo_camera;
    } else if (name.contains('bar')) {
      return Icons.local_bar;
    } else if (name.contains('pool')) {
      return Icons.pool;
    } else if (name.contains('garden')) {
      return Icons.grass;
    }

    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final icon = FacilityIcon.getIconForFacility(facilityName);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingSmall,
        vertical: AppTheme.paddingXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            facilityName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
