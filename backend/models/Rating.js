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
