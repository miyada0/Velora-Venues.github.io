const express = require('express');
const mongoose = require('mongoose');
const authMiddleware = require('../middleware/authMiddleware');
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
router.post('/:hallId', authMiddleware, async (req, res) => {
  try {
    const { hallId } = req.params;
    const { rating } = req.body;
    const userId = req.userId; // ✅ FIX: Use req.userId from authMiddleware
    
    console.log("🔵 [Rating POST] Starting rating submission...");
    console.log(`  userId: ${userId} (type: ${typeof userId})`);
    console.log(`  hallId: ${hallId} (type: ${typeof hallId})`);
    console.log(`  rating: ${rating} (type: ${typeof rating})`);

    // ✅ VALIDATION: User must be authenticated
    if (!userId) {
      console.log("❌ [Rating POST] userId is undefined - user not authenticated");
      return res.status(401).json({
        success: false,
        message: 'User not authenticated',
        error: 'MISSING_USER_ID'
      });
    }

    // ✅ VALIDATION: Rating must be provided
    if (rating === undefined || rating === null) {
      console.log("❌ [Rating POST] Rating not provided");
      return res.status(400).json({
        success: false,
        message: 'Rating is required',
        error: 'MISSING_RATING'
      });
    }

    // ✅ VALIDATION: Convert to number and validate range
    const numericRating = Number(rating);
    console.log(`  numericRating: ${numericRating} (converted from ${typeof rating})`);
    
    if (!Number.isFinite(numericRating) || numericRating < 1 || numericRating > 5) {
      console.log(`❌ [Rating POST] Invalid rating value: ${numericRating}`);
      return res.status(400).json({
        success: false,
        message: 'Rating must be a number between 1 and 5',
        error: 'INVALID_RATING',
        receivedValue: numericRating,
        receivedType: typeof numericRating
      });
    }

    // ✅ VALIDATION: Check if hall exists
    const hall = await Hall.findById(hallId);
    if (!hall) {
      console.log(`❌ [Rating POST] Hall not found: ${hallId}`);
      return res.status(404).json({
        success: false,
        message: 'Hall not found',
        error: 'HALL_NOT_FOUND',
        hallId
      });
    }

    console.log(`✅ Hall found: ${hall.name}`);

    // ✅ UPSERT: Update if exists, create if doesn't
    const ratingRecord = await Rating.findOneAndUpdate(
      { userId: new mongoose.Types.ObjectId(userId), hallId: new mongoose.Types.ObjectId(hallId) },
      {
        userId: new mongoose.Types.ObjectId(userId),
        hallId: new mongoose.Types.ObjectId(hallId),
        rating: numericRating,
        comment: req.body.comment || '',
      },
      { upsert: true, new: true, runValidators: true },
    );

    console.log(`🟢 [Rating POST] SUCCESS: Rating saved`);
    console.log(`  _id: ${ratingRecord._id}`);
    console.log(`  rating: ${ratingRecord.rating} (type: ${typeof ratingRecord.rating})`);

    // ✅ Return rating as Number (NOT String)
    return res.status(200).json({
      success: true,
      message: 'Rating submitted successfully',
      data: {
        _id: ratingRecord._id,
        rating: ratingRecord.rating,
        hallId: ratingRecord.hallId,
        userId: ratingRecord.userId,
        comment: ratingRecord.comment,
        createdAt: ratingRecord.createdAt,
        updatedAt: ratingRecord.updatedAt,
      },
    });
  } catch (error) {
    console.error('🔴 [Rating POST] Error submitting rating:', error.message);
    console.error('   Full error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to submit rating',
      error: error.message,
      errorType: error.name
    });
  }
});

/// 📥 GET /api/ratings/:hallId/my-rating
/// Get current user's rating for this hall
/// ✅ Returns rating as Number
router.get('/:hallId/my-rating', authMiddleware, async (req, res) => {
  try {
    const { hallId } = req.params;
    const userId = req.userId; // ✅ FIX: Use req.userId from authMiddleware
    
    console.log("🔵 [Rating GET my-rating] Fetching user rating...");
    console.log(`  userId: ${userId}`);
    console.log(`  hallId: ${hallId}`);

    // ✅ VALIDATION: User must be authenticated
    if (!userId) {
      console.log("❌ [Rating GET my-rating] userId is undefined");
      return res.status(401).json({
        success: false,
        message: 'User not authenticated',
        error: 'MISSING_USER_ID'
      });
    }

    const rating = await Rating.findOne({ 
      userId: new mongoose.Types.ObjectId(userId), 
      hallId: new mongoose.Types.ObjectId(hallId) 
    });

    if (!rating) {
      console.log(`⚠️  [Rating GET my-rating] No rating found for user ${userId} on hall ${hallId}`);
      return res.status(404).json({
        success: false,
        message: 'No rating found',
        error: 'NO_RATING_FOUND'
      });
    }

    console.log(`🟢 [Rating GET my-rating] SUCCESS: Found rating ${rating.rating}`);

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
    console.error('🔴 [Rating GET my-rating] Error:', error.message);
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
router.delete('/:hallId/my-rating', authMiddleware, async (req, res) => {
  try {
    const { hallId } = req.params;
    const userId = req.userId; // ✅ FIX: Use req.userId from authMiddleware
    
    console.log("🔵 [Rating DELETE] Deleting user rating...");
    console.log(`  userId: ${userId}`);
    console.log(`  hallId: ${hallId}`);

    // ✅ VALIDATION: User must be authenticated
    if (!userId) {
      console.log("❌ [Rating DELETE] userId is undefined");
      return res.status(401).json({
        success: false,
        message: 'User not authenticated',
        error: 'MISSING_USER_ID'
      });
    }

    const result = await Rating.findOneAndDelete({ 
      userId: new mongoose.Types.ObjectId(userId), 
      hallId: new mongoose.Types.ObjectId(hallId) 
    });

    if (!result) {
      console.log("⚠️  [Rating DELETE] No rating found to delete");
      return res.status(404).json({
        success: false,
        message: 'No rating found to delete',
        error: 'NO_RATING_FOUND'
      });
    }

    console.log(`🟢 [Rating DELETE] SUCCESS: Rating deleted`);

    return res.status(200).json({
      success: true,
      message: 'Rating deleted successfully',
    });
  } catch (error) {
    console.error('🔴 [Rating DELETE] Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete rating',
      error: error.message,
    });
  }
});

module.exports = router;
