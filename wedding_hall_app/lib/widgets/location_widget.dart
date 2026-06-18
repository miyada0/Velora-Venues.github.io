import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

/// 🗺️ CLICKABLE LOCATION WIDGET - Opens Google Maps
class LocationWidget extends StatefulWidget {
  final String locationText;
  final VoidCallback? onTap;

  const LocationWidget({
    super.key,
    required this.locationText,
    this.onTap,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  bool _isLoading = false;

  /// 🗺️ OPEN GOOGLE MAPS
  Future<void> _openGoogleMaps() async {
    setState(() => _isLoading = true);

    try {
      // Create Google Maps URL from location string
      final String encodedLocation = Uri.encodeComponent(widget.locationText);
      final String googleMapsUrl =
          "https://www.google.com/maps/search/$encodedLocation";

      // Try to launch Google Maps app (if installed)
      final Uri mapUri = Uri.parse(
        "geo:0,0?q=$encodedLocation",
      );

      // First try native maps app
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri);
      } else if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        // Fallback to web Google Maps
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Could not open maps. Please check your location."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      // Call optional callback
      widget.onTap?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error opening maps: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _openGoogleMaps,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          // Show hover effect on web/desktop
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            _isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[600]!,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.location_on,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.locationText,
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue.shade600,
                  decorationThickness: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.open_in_new,
              color: Colors.blue.shade600,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
