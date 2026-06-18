import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 💰 PRICE CARD WIDGET - Display pricing information
/// Used in Hall Cards, Details Screen, and Booking Summary
class PriceCard extends StatelessWidget {
  final double basePrice;
  final double? advancePrice;
  final String? label;
  final VoidCallback? onTap;
  final bool showAdvance;

  const PriceCard({
    super.key,
    required this.basePrice,
    this.advancePrice,
    this.label = "Base Price",
    this.onTap,
    this.showAdvance = false,
  });

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '₹${(price / 1000000).toStringAsFixed(1)}Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return '₹${(price / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${price.toInt()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium,
          vertical: AppTheme.paddingSmall,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryLight.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(
            color: AppTheme.primaryDark.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Text(
                  _formatPrice(basePrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
                if (showAdvance && advancePrice != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(advancePrice! / basePrice * 100).toInt()}% Advance',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
