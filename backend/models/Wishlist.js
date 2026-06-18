const mongoose = require("mongoose");

const wishlistSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    hall: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Hall",
      required: true,
    },
  },
  { timestamps: true }
);

// Prevent duplicate entries
wishlistSchema.index({ user: 1, hall: 1 }, { unique: true });

module.exports = mongoose.model("Wishlist", wishlistSchema);
