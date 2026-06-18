import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../services/rating_service.dart';
import '../../theme/app_theme.dart';

/// ⭐ HALL RATING & REVIEW WIDGET
class HallRatingWidget extends StatefulWidget {
  final String hallId;
  final double currentAverageRating;
  final VoidCallback? onRatingSubmitted;

  const HallRatingWidget({
    super.key,
    required this.hallId,
    required this.currentAverageRating,
    this.onRatingSubmitted,
  });

  @override
  State<HallRatingWidget> createState() => _HallRatingWidgetState();
}

class _HallRatingWidgetState extends State<HallRatingWidget> {
  late RatingService _ratingService;
  double? _userRating;
  bool _isSubmitting = false;
  double? _userCurrentRating;

  @override
  void initState() {
    super.initState();
    _ratingService = RatingService();
    _loadUserRating();
  }

  /// 📥 FETCH USER'S CURRENT RATING FOR THIS HALL
  /// ✅ SAFE: Handles rating as double, int, or string from API
  Future<void> _loadUserRating() async {
    try {
      final userRating = await _ratingService.getUserRatingForHall(
        widget.hallId,
      );

      if (mounted && userRating != null) {
        // ✅ SAFE: Convert rating from any type to double
        final rating = _extractRatingAsDouble(userRating["rating"]);

        setState(() {
          _userCurrentRating = rating;
          _userRating = rating;
        });

        debugPrint("🟢 [HallRatingWidget] Loaded user rating: $rating");
      }
    } catch (e) {
      // Silently fail - user just hasn't rated yet
      debugPrint("🔴 [HallRatingWidget] Error loading user rating: $e");
    }
  }

  /// ✅ HELPER: Safe conversion from any type to double
  double _extractRatingAsDouble(dynamic value) {
    debugPrint(
        "🔵 [HallRatingWidget] Raw rating value: $value (type: ${value.runtimeType})");

    if (value == null) return 0.0;

    // Already a double? Return it
    if (value is double) {
      debugPrint("✅ Rating is already double: $value");
      return value;
    }

    // Integer? Convert to double
    if (value is int) {
      final result = value.toDouble();
      debugPrint("✅ Converted int to double: $value → $result");
      return result;
    }

    // String? Parse it carefully
    if (value is String) {
      try {
        final parsed = double.parse(value);
        debugPrint("✅ Parsed String to double: '$value' → $parsed");
        return parsed;
      } catch (e) {
        debugPrint("❌ Failed to parse String '$value': $e");
        return 0.0;
      }
    }

    // Unknown type? Default to 0.0
    debugPrint("⚠️ Unknown type for rating: ${value.runtimeType}");
    return 0.0;
  }

  /// ⭐ SUBMIT RATING TO BACKEND
  /// ✅ SAFE: Validates rating before sending
  Future<void> _submitRating(double rating) async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // ✅ Ensure rating is valid (1-5)
      if (rating < 1 || rating > 5) {
        throw Exception("Rating must be between 1 and 5");
      }

      debugPrint("🔵 [HallRatingWidget] Submitting rating: $rating");

      // ignore: unused_local_variable
      final result = await _ratingService.submitRating(
        hallId: widget.hallId,
        rating: rating,
      );

      if (mounted) {
        setState(() {
          _userRating = rating;
          _userCurrentRating = rating;
          _isSubmitting = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Thank you! You rated this hall $rating ⭐"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        debugPrint("🟢 [HallRatingWidget] Rating submitted successfully");

        // Callback to parent to refresh hall data
        widget.onRatingSubmitted?.call();
      }
    } catch (e) {
      debugPrint("🔴 [HallRatingWidget] Error submitting rating: $e");

      if (mounted) {
        setState(() => _isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit rating: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 📊 HEADER WITH AVERAGE RATING
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Rate This Hall",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.currentAverageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.paddingMedium),

          /// ⭐ RATING BAR
          Center(
            child: Column(
              children: [
                RatingBar.builder(
                  initialRating: _userRating ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber.shade600,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() => _userRating = rating);
                  },
                  updateOnDrag: true,
                ),
                const SizedBox(height: 12),
                if (_userRating != null && _userRating! > 0)
                  Text(
                    "You rated ${_userRating!.toStringAsFixed(1)} ⭐",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.paddingMedium),

          /// ✅ SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_userRating != null && _userRating! > 0) {
                        _submitRating(_userRating!);
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _userCurrentRating != null
                          ? "Update Rating"
                          : "Submit Rating",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          /// 💡 HINT TEXT
          const SizedBox(height: 12),
          Text(
            _userCurrentRating != null
                ? "You have already rated this hall. Update your rating to change it."
                : "Share your experience to help other couples find their perfect venue!",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
