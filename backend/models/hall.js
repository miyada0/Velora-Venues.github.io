const mongoose = require("mongoose");

const hallSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    location: {
      type: String,
      required: true,
      trim: true,
    },

    price: {
      type: Number,
      required: true,
      min: 0,
    },

    images: {
      type: [String],
      default: [],
    },

    facilities: {
      type: [String],
      default: [],
    },

    capacity: {
      type: Number,
      default: 0,
    },

    description: {
      type: String,
      default: "",
    },

    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },

    reviewsCount: {
      type: Number,
      default: 0,
    },

    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    status: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },
  },
  { timestamps: true }
);

/* 🔥 Indexes for faster filtering */

hallSchema.index({ location: 1 });
hallSchema.index({ price: 1 });
hallSchema.index({ rating: -1 });
hallSchema.index({ capacity: 1 });

module.exports = mongoose.model("Hall", hallSchema);