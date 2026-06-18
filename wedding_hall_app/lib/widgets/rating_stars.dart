import 'package:flutter/material.dart';
//import '../theme/app_theme.dart';

/// ⭐ REUSABLE RATING STARS WIDGET
/// Shows 5 stars and optionally allows interaction
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final int maxRating;
  final bool interactive;
  final Function(double)? onRatingChanged;
  final EdgeInsets padding;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 24,
    this.maxRating = 5,
    this.interactive = false,
    this.onRatingChanged,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          maxRating,
          (index) {
            final isFilledStar = index < rating.floor();
            final isHalfStar = index < rating && index >= rating.floor();

            return interactive
                ? GestureDetector(
                    onTap: () {
                      onRatingChanged?.call(index + 1.0);
                    },
                    child: _buildStar(isFilledStar, isHalfStar),
                  )
                : _buildStar(isFilledStar, isHalfStar);
          },
        ),
      ),
    );
  }

  Widget _buildStar(bool isFilled, bool isHalf) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: isHalf
          ? SizedBox(
              width: size,
              height: size,
              child: Stack(
                children: [
                  Icon(
                    Icons.star_outline,
                    size: size,
                    color: Colors.amber.shade200,
                  ),
                  Positioned(
                    width: size / 2,
                    height: size,
                    child: Icon(
                      Icons.star,
                      size: size,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            )
          : Icon(
              isFilled ? Icons.star : Icons.star_outline,
              size: size,
              color: isFilled ? Colors.amber : Colors.amber.shade200,
            ),
    );
  }
}
