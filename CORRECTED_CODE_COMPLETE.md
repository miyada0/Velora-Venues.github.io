# Complete Corrected Code - Copy & Paste Ready

---

## 1️⃣ Frontend Service - Rating Service

**File:** `lib/services/rating_service.dart`

### ✅ Complete Corrected Code

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';

class RatingService {
  final api = ApiService();

  /// ======== SUBMIT USER RATING ========
  /// POST /api/ratings/:hallId
  /// Body: { "rating": number }
  /// ✅ Ensures rating is always sent as numeric value
  Future<Map<String, dynamic>> submitRating({
    required String hallId,
    required double rating,
  }) async {
    try {
      // ✅ Ensure rating is double, not string
      final numericRating = double.parse(rating.toString());
      
      debugPrint("🔵 [RatingService] Submitting rating: $numericRating (type: ${numericRating.runtimeType})");

      final response = await api.dio.post(
        "/ratings/$hallId",
        data: {
          "rating": numericRating, // ✅ Always numeric
        },
      );

      // ✅ Validate response is a Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      debugPrint("🟢 [RatingService] Response: ${response.data}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint("🔴 [RatingService] Error: ${e.response?.statusCode}");
      throw Exception(
        "Failed to submit rating: ${e.response?.data?['message'] ?? e.message}",
      );
    }
  }

  /// ======== GET HALL RATING DATA ========
  /// GET /api/ratings/:hallId
  /// ✅ Returns rating as number for safe calculations
  Future<Map<String, dynamic>> getHallRatingData(String hallId) async {
    try {
      final response = await api.dio.get("/ratings/$hallId");

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      final data = response.data as Map<String, dynamic>;
      
      // ✅ Ensure rating in response is numeric
      if (data['rating'] != null) {
        data['rating'] = _parseRatingToDouble(data['rating']);
      }

      return data;
    } on DioException catch (e) {
      throw Exception(
        "Failed to fetch rating data: ${e.response?.data?['message'] ?? e.message}",
      );
    }
  }

  /// ======== GET USER'S RATING FOR HALL ========
  /// GET /api/ratings/:hallId/my-rating
  /// ✅ Safely converts rating from any type to double
  Future<Map<String, dynamic>?> getUserRatingForHall(String hallId) async {
    try {
      final response = await api.dio.get("/ratings/$hallId/my-rating");

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      final data = response.data as Map<String, dynamic>;
      
      // ✅ Ensure rating is always double, regardless of backend format
      if (data['rating'] != null) {
        data['rating'] = _parseRatingToDouble(data['rating']);
      }

      return data;
    } on DioException catch (e) {
      // 404 means user hasn't rated this hall yet - that's ok
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(
        "Failed to fetch user rating: ${e.response?.data?['message'] ?? e.message}",
      );
    }
  }

  /// ✅ HELPER: Safe rating conversion from any type
  /// Handles: double, int, String, null
  static double _parseRatingToDouble(dynamic value) {
    if (value == null) return 0.0;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    
    return 0.0; // Default fallback
  }
}
```

---

## 2️⃣ Frontend Widget - Hall Rating Widget

**File:** `lib/widgets/hall_rating_widget.dart`

### Key Changes (Methods to Update)

#### UPDATE #1: Add new helper method

Add this method to the `_HallRatingWidgetState` class:

```dart
/// ✅ SAFE: Convert rating from any type (double, int, String) to double
double _extractRatingAsDouble(dynamic value) {
  debugPrint("🔵 [HallRatingWidget] Raw rating value: $value (type: ${value.runtimeType})");
  
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
```

#### UPDATE #2: Replace _loadUserRating() method

```dart
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
```

#### UPDATE #3: Replace _submitRating() method

```dart
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
```

---

## 3️⃣ Backend Model - Rating

**File NEW:** `backend/models/Rating.js`

### Complete File

```javascript
const mongoose = require('mongoose');

/// ⭐ RATING SCHEMA
/// ✅ Stores user ratings for halls
/// ✅ Ensures rating is ALWAYS stored as Number type (not String)
const ratingSchema = new mongoose.Schema(
  {
    // ✅ Reference to the hall being rated
    hallId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Hall',
      required: true,
      index: true,
    },

    // ✅ User who submitted the rating
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },

    // ⭐ CRITICAL: Rating is stored as Number, NOT String
    // This prevents the "String is not subtype of int" error
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
      validate: {
        validator: (val) => Number.isFinite(val) && val >= 1 && val <= 5,
        message: 'Rating must be a number between 1 and 5',
      },
    },

    // Optional review text
    comment: {
      type: String,
      trim: true,
      maxlength: 500,
    },
  },
  {
    timestamps: true, // createdAt, updatedAt
  },
);

/// ✅ Prevent duplicate ratings from same user for same hall
/// If user rates hall again, it updates the existing rating
ratingSchema.index({ userId: 1, hallId: 1 }, { unique: true });

module.exports = mongoose.model('Rating', ratingSchema);
```

---

## 4️⃣ Backend Routes - Rating API

**File NEW:** `backend/routes/ratingRoutes.js`

### Complete File

```javascript
const express = require('express');
const mongoose = require('mongoose');
const protect = require('../middleware/authMiddleware');
const Rating = require('../models/Rating');
const Hall = require('../models/hall');

const router = express.Router();

/// ============================================
/// ⭐ RATING API ENDPOINTS
/// ✅ All ratings stored/returned as Numbers
/// ✅ Prevents "String is not subtype of int" error
/// ============================================

/// 📤 POST /api/ratings/:hallId
/// Submit or update user rating for a hall
/// ✅ Ensures rating is saved as Number in MongoDB
router.post('/:hallId', protect, async (req, res) => {
  try {
    const { hallId } = req.params;
    const { rating } = req.body;
    const userId = req.user.id;

    // ✅ VALIDATION: Rating must be provided
    if (rating === undefined || rating === null) {
      return res.status(400).json({
        success: false,
        message: 'Rating is required',
      });
    }

    // ✅ VALIDATION: Convert to number and validate range
    const numericRating = Number(rating);
    if (!Number.isFinite(numericRating) || numericRating < 1 || numericRating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be a number between 1 and 5',
      });
    }

    // ✅ VALIDATION: Check if hall exists
    const hall = await Hall.findById(hallId);
    if (!hall) {
      return res.status(404).json({
        success: false,
        message: 'Hall not found',
      });
    }

    // ✅ UPSERT: Update if exists, create if doesn't
    // unique index on userId + hallId ensures only one rating per user per hall
    const ratingRecord = await Rating.findOneAndUpdate(
      { userId, hallId },
      {
        userId,
        hallId,
        rating: numericRating, // ✅ ALWAYS stored as Number
        comment: req.body.comment || '',
      },
      { upsert: true, new: true, runValidators: true },
    );

    console.log(`🟢 [Rating API] Rating submitted: User ${userId} → Hall ${hallId} = ${numericRating} stars (Type: ${typeof numericRating})`);

    // ✅ Return rating as Number (NOT String)
    return res.status(200).json({
      success: true,
      message: 'Rating submitted successfully',
      data: {
        _id: ratingRecord._id,
        rating: ratingRecord.rating, // Number type
        hallId: ratingRecord.hallId,
        userId: ratingRecord.userId,
        comment: ratingRecord.comment,
        createdAt: ratingRecord.createdAt,
        updatedAt: ratingRecord.updatedAt,
      },
    });
  } catch (error) {
    console.error('🔴 [Rating API] Error submitting rating:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to submit rating',
      error: error.message,
    });
  }
});

/// 📥 GET /api/ratings/:hallId/my-rating
/// Get current user's rating for this hall
/// ✅ Returns rating as Number
router.get('/:hallId/my-rating', protect, async (req, res) => {
  try {
    const { hallId } = req.params;
    const userId = req.user.id;

    const rating = await Rating.findOne({ userId, hallId });

    if (!rating) {
      return res.status(404).json({
        success: false,
        message: 'No rating found',
      });
    }

    console.log(`🟢 [Rating API] User rating retrieved: ${rating.rating} (Type: ${typeof rating.rating})`);

    // ✅ Return rating as Number
    return res.status(200).json({
      success: true,
      data: {
        _id: rating._id,
        rating: rating.rating, // Number type
        comment: rating.comment,
        createdAt: rating.createdAt,
      },
    });
  } catch (error) {
    console.error('🔴 [Rating API] Error fetching user rating:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch rating',
      error: error.message,
    });
  }
});

/// 📊 GET /api/ratings/:hallId
/// Get all rating stats for a hall
/// ✅ Returns average rating as Number
router.get('/:hallId', async (req, res) => {
  try {
    const { hallId } = req.params;

    // ✅ Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(hallId)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid hall ID',
      });
    }

    const ratings = await Rating.find({ hallId });

    if (ratings.length === 0) {
      return res.status(200).json({
        success: true,
        data: {
          averageRating: 0, // Number
          totalRatings: 0,
          ratingDistribution: {
            5: 0,
            4: 0,
            3: 0,
            2: 0,
            1: 0,
          },
        },
      });
    }

    // ✅ Calculate average as Number
    const totalSum = ratings.reduce((sum, r) => sum + (r.rating || 0), 0);
    const averageRating = totalSum / ratings.length;

    // Count ratings by star
    const distribution = {
      5: ratings.filter((r) => r.rating === 5).length,
      4: ratings.filter((r) => r.rating === 4).length,
      3: ratings.filter((r) => r.rating === 3).length,
      2: ratings.filter((r) => r.rating === 2).length,
      1: ratings.filter((r) => r.rating === 1).length,
    };

    console.log(`🟢 [Rating API] Hall ${hallId} average: ${averageRating} (Type: ${typeof averageRating})`);

    return res.status(200).json({
      success: true,
      data: {
        averageRating: Number(averageRating.toFixed(2)), // Ensure Number
        totalRatings: ratings.length,
        ratingDistribution: distribution,
      },
    });
  } catch (error) {
    console.error('🔴 [Rating API] Error fetching rating stats:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch rating stats',
      error: error.message,
    });
  }
});

/// 🗑️ DELETE /api/ratings/:hallId/my-rating
/// Delete user's rating for this hall
router.delete('/:hallId/my-rating', protect, async (req, res) => {
  try {
    const { hallId } = req.params;
    const userId = req.user.id;

    const result = await Rating.findOneAndDelete({ userId, hallId });

    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'No rating found to delete',
      });
    }

    console.log(`🟢 [Rating API] Rating deleted: User ${userId} → Hall ${hallId}`);

    return res.status(200).json({
      success: true,
      message: 'Rating deleted successfully',
    });
  } catch (error) {
    console.error('🔴 [Rating API] Error deleting rating:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete rating',
      error: error.message,
    });
  }
});

module.exports = router;
```

---

## 5️⃣ Backend Server Configuration

**File:** `backend/server.js`

### Change Required

Find this section:
```javascript
const authRoutes = require("./routes/authRoutes");
const hallRoutes = require("./routes/hallRoutes");
const bookingRoutes = require("./routes/bookingRoutes");
const reviewRoutes = require("./routes/reviewRoutes");
const adminRoutes = require("./routes/adminRoutes");
const notificationRoutes = require("./routes/NotificationRoutes");
const wishlistRoutes = require("./routes/WishlistRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
```

**Add:**
```javascript
const ratingRoutes = require("./routes/ratingRoutes");
```

Then find this section:
```javascript
app.use("/api/auth", authRoutes);
app.use("/api/halls", hallRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/wishlist", wishlistRoutes);
app.use("/api/reviews", reviewRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/payment", paymentRoutes);
```

**Add:**
```javascript
app.use("/api/ratings", ratingRoutes);
```

---

## Summary of Changes

| File | Lines Changed | Type |
|------|-----|------|
| `lib/services/rating_service.dart` | +70 | Modified |
| `lib/widgets/hall_rating_widget.dart` | +80 | Modified |
| `backend/models/Rating.js` | +50 | NEW |
| `backend/routes/ratingRoutes.js` | +200 | NEW |
| `backend/server.js` | +2 | Modified |

---

## Verification

After applying all changes:

1. ✅ No `String is not subtype of int` errors
2. ✅ Rating system works end-to-end
3. ✅ All debug logs show correct types
4. ✅ MongoDB stores rating as Number
5. ✅ Frontend safely handles all rating types

---

**All code is ready to copy and paste! 🚀**
