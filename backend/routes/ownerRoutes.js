const express = require("express");
const router = express.Router();
const Hall = require("../models/hall");
const Booking = require("../models/Booking");
const {
  authMiddleware,
  ownerOnly,
} = require("../middleware/rbacMiddleware");

/* ================= GET OWNER HALL (Owners only) ================= */

router.get("/my-hall", authMiddleware, ownerOnly, async (req, res) => {
  try {
    const hall = await Hall.findOne({ owner: req.userId });

    if (!hall) {
      return res.status(404).json({
        message: "No hall found for this owner",
      });
    }

    res.json(hall);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= GET OWNER BOOKINGS (Owners only) ================= */

router.get("/bookings", authMiddleware, ownerOnly, async (req, res) => {
  try {
    const hall = await Hall.findOne({ owner: req.userId });

    if (!hall) {
      return res.status(404).json({
        message: "No hall found for this owner",
      });
    }

    const bookings = await Booking.find({ hall: hall._id })
      .populate("user", "name email")
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= GET OWNER EARNINGS (Owners only) ================= */

router.get("/earnings", authMiddleware, ownerOnly, async (req, res) => {
  try {
    const hall = await Hall.findOne({ owner: req.userId });

    if (!hall) {
      return res.status(404).json({
        message: "No hall found for this owner",
      });
    }

    const bookings = await Booking.find({
      hall: hall._id,
      paymentStatus: "paid",
      isCancelled: false,
    });

    const totalEarnings = bookings.reduce(
      (sum, booking) => sum + (booking.advancePaid || 0),
      0
    );

    res.json({
      totalBookings: bookings.length,
      totalEarnings,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= GET OWNER STATISTICS (Owners only) ================= */

router.get("/stats", authMiddleware, ownerOnly, async (req, res) => {
  try {
    const hall = await Hall.findOne({ owner: req.userId });

    if (!hall) {
      return res.status(404).json({
        message: "No hall found for this owner",
      });
    }

    // Get all bookings for this hall
    const allBookings = await Booking.find({ hall: hall._id });

    // Active bookings (upcoming, not cancelled)
    const activeBookings = allBookings.filter((b) => !b.isCancelled);

    // Cancelled bookings
    const cancelledBookings = allBookings.filter((b) => b.isCancelled);

    // Total revenue (paid bookings only)
    const totalRevenue = activeBookings
      .filter((b) => b.paymentStatus === "paid")
      .reduce((sum, b) => sum + (b.advancePaid || b.amount || 0), 0);

    // Pending payments
    const pendingPayments = activeBookings
      .filter((b) => b.paymentStatus !== "paid")
      .reduce((sum, b) => sum + (b.amount || 0), 0);

    // Upcoming bookings (within 30 days)
    const today = new Date();
    const thirtyDaysLater = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000);
    const upcomingBookings = activeBookings.filter((b) => {
      const bookingDate = new Date(b.date);
      return bookingDate >= today && bookingDate <= thirtyDaysLater;
    });

    res.json({
      totalBookings: allBookings.length,
      activeBookings: activeBookings.length,
      cancelledBookings: cancelledBookings.length,
      upcomingBookings: upcomingBookings.length,
      totalRevenue,
      pendingPayments,
      hallName: hall.name,
      hallId: hall._id,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;