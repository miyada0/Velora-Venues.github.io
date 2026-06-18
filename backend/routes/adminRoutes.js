const express = require("express");
const router = express.Router();

const Hall = require("../models/hall");
const User = require("../models/User");
const Booking = require("../models/Booking");

const {
  authMiddleware,
  adminOnly,
} = require("../middleware/rbacMiddleware");

/* ================= OWNER DASHBOARD ================= */
router.get("/owner/dashboard", authMiddleware, async (req, res) => {
  try {
    // Get halls owned by this user
    const totalHalls = await Hall.countDocuments({ owner: req.userId });

    // Get bookings for those halls
    const halls = await Hall.find({ owner: req.userId }).select("_id");
    const hallIds = halls.map((h) => h._id);

    const totalBookings = await Booking.countDocuments({
      hall: { $in: hallIds },
    });

    const activeBookings = await Booking.countDocuments({
      hall: { $in: hallIds },
      isCancelled: false,
    });

    const bookings = await Booking.find({
      hall: { $in: hallIds },
      isCancelled: false,
    });

    const totalRevenue = bookings.reduce((sum, b) => sum + b.amount, 0);

    res.json({
      success: true,
      totalHalls,
      totalBookings,
      activeBookings,
      totalRevenue,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

/* ================= STATS ================= */

router.get(
  "/stats",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const totalUsers = await User.countDocuments();
      const totalHalls = await Hall.countDocuments();
      const totalBookings = await Booking.countDocuments();

      const bookings = await Booking.find({
        isCancelled: false,
      });

      const totalRevenue = bookings.reduce(
        (sum, b) => sum + b.amount,
        0
      );

      res.json({
        totalUsers,
        totalHalls,
        totalBookings,
        totalRevenue,
      });

    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

/* ================= GET ALL HALLS ================= */

router.get(
  "/halls",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const halls = await Hall.find()
        .populate("owner", "name email");

      res.json(halls);

    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

/* ================= DELETE HALL (Admin Only) ================= */
router.delete(
  "/halls/:id",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const hall = await Hall.findById(req.params.id);

      if (!hall) {
        return res.status(404).json({
          success: false,
          message: "Hall not found",
        });
      }

      // ✅ FIX #3: Delete associated bookings too
      await Booking.deleteMany({ hall: req.params.id });

      // Delete the hall
      await Hall.findByIdAndDelete(req.params.id);

      res.json({
        success: true,
        message: "Hall deleted successfully",
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }
);

/* ================= GET PENDING HALLS ================= */

router.get(
  "/pending-halls",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const halls = await Hall.find({ status: "pending" })
        .populate("owner", "name email");

      res.json(halls);

    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

/* ================= APPROVE HALL ================= */

router.put(
  "/approve/:id",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const hall = await Hall.findByIdAndUpdate(
        req.params.id,
        { status: "approved" },
        { new: true }
      ).populate("owner", "name email");

      res.json({
        message: "Hall approved",
        hall,
      });

    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

/* ================= REJECT HALL ================= */

router.put(
  "/reject/:id",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const hall = await Hall.findByIdAndUpdate(
        req.params.id,
        { status: "rejected" },
        { new: true }
      ).populate("owner", "name email");

      res.json({
        message: "Hall rejected",
        hall,
      });

    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

/* ================= GET ALL USERS ================= */

router.get(
  "/users",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const users = await User.find()
        .select("-password");

      res.json(users);

    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

/* ================= DELETE USER ================= */

router.delete(
  "/user/:id",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const user = await User.findByIdAndDelete(req.params.id);

      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      res.json({
        message: "User deleted successfully",
        user,
      });

    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

/* ================= GET ALL BOOKINGS ================= */

router.get(
  "/bookings",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const bookings = await Booking.find()
        .populate("hall")
        .populate("user", "name email");

      res.json(bookings);

    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

/* ================= MIGRATE: SET ALL BOOKINGS TO PAID ================= */
/* Run once to update existing bookings */

router.post(
  "/migrate/bookings-paid",
  authMiddleware,
  adminOnly,
  async (req, res) => {
    try {
      const result = await Booking.updateMany(
        { paymentStatus: { $ne: "paid" } },  // Update only non-paid
        { paymentStatus: "paid" }
      );

      res.json({
        message: "Migration complete",
        updatedCount: result.modifiedCount,
        totalBookings: await Booking.countDocuments(),
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

module.exports = router;