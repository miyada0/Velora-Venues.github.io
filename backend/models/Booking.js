const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema(
  {
    hall: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Hall",
      required: true,
    },

    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    date: {
      type: Date,
      required: true,
    },

    amount: {
      type: Number,
      required: true,
    },

    paymentStatus: {
      type: String,
      enum: ["pending", "paid", "failed"],
      default: "paid",
    },

    isCancelled: {
      type: Boolean,
      default: false,
    },

    /* ======== NEW BOOKING FORM FIELDS ======== */

    fullName: {
      type: String,
      required: true,
      trim: true,
    },

    phone: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
    },

    eventType: {
      type: String,
      enum: ["wedding", "corporate", "birthday", "anniversary", "other"],
      default: "wedding",
    },

    startTime: {
      type: String,
      required: true,
    },

    endTime: {
      type: String,
      required: true,
    },

    numberOfGuests: {
      type: Number,
      required: true,
      min: 1,
    },

    totalAmount: {
      type: Number,
      required: true,
    },

    advanceAmount: {
      type: Number,
      default: 0,
    },

    specialRequests: {
      type: String,
      default: "",
    },

    cateringRequired: {
      type: Boolean,
      default: false,
    },

    decorationRequired: {
      type: Boolean,
      default: false,
    },

    photographyRequired: {
      type: Boolean,
      default: false,
    },

    bookingStatus: {
      type: String,
      enum: ["confirmed", "pending", "completed", "cancelled"],
      default: "confirmed",
    },

    adminApproval: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },

    paymentMethod: {
      type: String,
      enum: ["card", "upi", "net_banking", "wallet"],
      default: "card",
    },
  },
  {
    timestamps: true,
  }
);

/* ========================================
   Prevent duplicate bookings for same hall
   (handled in routes, but index helps)
======================================== */

bookingSchema.index(
  { hall: 1, date: 1 },
  { unique: false }
);

module.exports = mongoose.model("Booking", bookingSchema);