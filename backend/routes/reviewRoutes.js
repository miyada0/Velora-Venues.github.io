const express = require("express");
const router = express.Router();

const Review = require("../models/Review");
const Booking = require("../models/Booking");
const Hall = require("../models/hall");
const Notification = require("../models/Notification");
const { authMiddleware } = require("../middleware/rbacMiddleware");

/* ================= ADD REVIEW ================= */

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { hallId, bookingId, rating, comment } = req.body;

    if (!hallId || !bookingId || !rating) {
      return res.status(400).json({
        message: "Hall, booking and rating are required",
      });
    }

    // ✅ Check booking exists and belongs to user
    const booking = await Booking.findById(bookingId);

    if (!booking || booking.user.toString() !== req.userId) {
      return res.status(403).json({
        message: "You can only review your booking",
      });
    }

    // ✅ Prevent duplicate review
    const existingReview = await Review.findOne({
      booking: bookingId,
    });

    if (existingReview) {
      return res.status(400).json({
        message: "You already reviewed this booking",
      });
    }

    const review = await Review.create({
      user: req.userId,
      hall: hallId,
      booking: bookingId,
      rating,
      comment,
    });

    // 🔔 Notify hall owner
    const hall = await Hall.findById(hallId);

    if (hall) {
      await Notification.create({
        user: hall.owner,
        title: "New Review",
        message: `Your hall ${hall.name} received a new review.`,
      });
    }

    res.json({
      message: "Review added successfully",
      review,
    });

  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= GET HALL REVIEWS ================= */

router.get("/:hallId", async (req, res) => {
  try {
    const reviews = await Review.find({
      hall: req.params.hallId,
    })
      .populate("user", "name")
      .sort({ createdAt: -1 });

    res.json(reviews);

  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= OWNER REPLY TO REVIEW ================= */

router.put("/reply/:reviewId", authMiddleware, async (req, res) => {
  try {
    const { reply } = req.body;

    if (!reply) {
      return res.status(400).json({
        message: "Reply cannot be empty",
      });
    }

    const review = await Review.findById(req.params.reviewId)
      .populate("hall");

    if (!review) {
      return res.status(404).json({
        message: "Review not found",
      });
    }

    // ✅ Ensure only hall owner can reply
    if (review.hall.owner.toString() !== req.userId) {
      return res.status(403).json({
        message: "Unauthorized",
      });
    }

    review.ownerReply = reply;
    await review.save();

    // 🔔 Notify user about reply
    await Notification.create({
      user: review.user,
      title: "Owner Replied",
      message: `Owner replied to your review.`,
    });

    res.json({
      message: "Reply added successfully",
      review,
    });

  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

module.exports = router;