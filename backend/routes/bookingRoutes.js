const express = require("express");
const router = express.Router();
const crypto = require("crypto");

const Booking = require("../models/Booking");
const Hall = require("../models/hall");
const Notification = require("../models/Notification");
const {
  authMiddleware,
  userOnly,
  adminOnly,
} = require("../middleware/rbacMiddleware");

/* ================= CREATE BOOKING (Users ONLY - Blocks admins/owners) ================= */

router.post("/", authMiddleware, userOnly, async (req, res) => {
  try {
    const {
      hallId,
      date,
      fullName,
      phone,
      email,
      eventType,
      startTime,
      endTime,
      numberOfGuests,
      totalAmount,
      advanceAmount,
      specialRequests,
      cateringRequired,
      decorationRequired,
      photographyRequired,
      paymentMethod,
    } = req.body;

    /* ===== VALIDATE REQUIRED FIELDS ===== */
    if (!hallId || !date) {
      return res.status(400).json({
        error: "Hall and date required",
      });
    }

    if (!fullName || !phone || !email) {
      return res.status(400).json({
        error: "Full Name, Phone, and Email are required",
      });
    }

    const hall = await Hall.findById(hallId);

    if (!hall) {
      return res.status(404).json({
        error: "Hall not found",
      });
    }

    const bookingDate = new Date(date);

    /* ===== CHECK DOUBLE BOOKING ===== */
    const existingBooking = await Booking.findOne({
      hall: hallId,
      date: bookingDate,
      isCancelled: false,
    });

    if (existingBooking) {
      return res.status(400).json({
        error: "Selected date is already booked",
      });
    }

    /* ===== CREATE BOOKING WITH FORM DATA ===== */
    const booking = await Booking.create({
      user: req.userId,
      hall: hallId,
      date: bookingDate,
      amount: hall.price,
      fullName,
      phone,
      email,
      eventType: eventType || "wedding",
      startTime,
      endTime,
      numberOfGuests,
      totalAmount: totalAmount || hall.price,
      advanceAmount: advanceAmount || (hall.price * 0.2),
      specialRequests: specialRequests || "",
      cateringRequired: cateringRequired || false,
      decorationRequired: decorationRequired || false,
      photographyRequired: photographyRequired || false,
      paymentMethod: paymentMethod || "card",
      paymentStatus: "paid",  // ✅ FIX #6: Set to "paid" immediately
      bookingStatus: "confirmed",
      adminApproval: "pending",
      isCancelled: false,
    });

    /* ===== POPULATE HALL & USER DATA BEFORE RETURNING ===== */
    const populatedBooking = await Booking.findById(booking._id)
      .populate("hall")
      .populate("user", "name email");

    /* ===== USER NOTIFICATION ===== */
    await Notification.create({
      user: req.userId,
      title: "Booking Confirmed",
      message: `Your booking for ${hall.name} on ${bookingDate.toDateString()} is confirmed.`,
    });

    /* ===== OWNER NOTIFICATION ===== */
    await Notification.create({
      user: hall.owner,
      title: "New Booking",
      message: `New booking received for ${hall.name} from ${fullName}.`,
    });

    res.json({
      message: "Booking successful",
      bookingId: booking._id,
      booking: populatedBooking,
    });
  } catch (error) {
    console.log("❌ Booking creation error:", error.message);
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= GET USER BOOKINGS ================= */
router.get("/user", authMiddleware, async (req, res) => {
  try {
    const bookings = await Booking.find({
      user: req.userId,
      isCancelled: false,
    })
      .populate("hall")
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= ADMIN VIEW ALL BOOKINGS ================= */
router.get("/admin", authMiddleware, adminOnly, async (req, res) => {
  try {
    const bookings = await Booking.find()
      .populate("hall")
      .populate("user", "name email")
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= OWNER BOOKINGS FOR THEIR HALLS ================= */
router.get("/owner/hall/:hallId", authMiddleware, async (req, res) => {
  try {
    const hall = await Hall.findById(req.params.hallId);
    
    // Verify owner
    if (hall.owner.toString() !== req.userId) {
      return res.status(403).json({
        error: "Unauthorized - you do not own this hall",
      });
    }

    const bookings = await Booking.find({
      hall: req.params.hallId,
    })
      .populate("user", "name email phone")
      .sort({ date: -1 });

    // Calculate stats
    const totalBookings = bookings.length;
    const activeBookings = bookings.filter(b => !b.isCancelled).length;
    const totalRevenue = bookings
      .filter(b => !b.isCancelled)
      .reduce((sum, b) => sum + b.amount, 0);

    res.json({
      bookings,
      stats: {
        totalBookings,
        activeBookings,
        totalRevenue,
      }
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= CANCEL BOOKING (with 2-day rule) ================= */
router.put("/cancel/:id", authMiddleware, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    // Check ownership
    if (booking.user.toString() !== req.userId) {
      return res.status(403).json({
        success: false,
        message: "Unauthorized - you cannot cancel this booking",
      });
    }

    // ✅ FIX #1: Check 2-day rule with clear message
    const bookingDate = new Date(booking.date);
    const now = new Date();
    const hoursLeft = (bookingDate - now) / (1000 * 60 * 60);

    if (hoursLeft < 48) {
      return res.status(400).json({
        success: false,
        message: "Cannot cancel booking within 2 days of event date",
        hoursLeft: Math.ceil(hoursLeft),
        error: "CANCEL_RESTRICTION",
      });
    }

    booking.isCancelled = true;
    await booking.save();

    // ✅ FIX #2: Free the date from hall's bookedDates
    const hallForDateUpdate = await Hall.findById(booking.hall);
    if (hallForDateUpdate && hallForDateUpdate.bookedDates && hallForDateUpdate.bookedDates.length > 0) {
      // Remove the booking date from bookedDates
      const bookingDateStr = new Date(booking.date).toISOString().split('T')[0];
      hallForDateUpdate.bookedDates = hallForDateUpdate.bookedDates.filter(date => {
        const dateStr = new Date(date).toISOString().split('T')[0];
        return dateStr !== bookingDateStr;
      });
      await hallForDateUpdate.save();
    }

    // Notification
    const hall = await Hall.findById(booking.hall);
    await Notification.create({
      user: req.userId,
      title: "Booking Cancelled",
      message: `Your booking for ${hall.name} has been cancelled.`,
    });

    res.json({
      success: true,
      message: "Booking cancelled successfully",
      booking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

/* ================= GET BOOKED DATES ================= */
router.get("/hall/:hallId/booked-dates", async (req, res) => {
  try {
    const bookings = await Booking.find({
      hall: req.params.hallId,
      isCancelled: false,
    });

    const bookedDates = bookings.map((b) => b.date);

    res.json(bookedDates);
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= OWNER EARNINGS ================= */
router.get("/owner/earnings", authMiddleware, async (req, res) => {
  try {
    const halls = await Hall.find({
      owner: req.userId,
    });

    const hallIds = halls.map((h) => h._id);

    const bookings = await Booking.find({
      hall: { $in: hallIds },
      isCancelled: false,
    });

    const totalEarnings = bookings.reduce(
      (sum, booking) => sum + booking.amount,
      0
    );

    res.json({
      totalEarnings,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= OWNER STATS ================= */
router.get("/owner/stats", authMiddleware, async (req, res) => {
  try {
    const ownerId = req.userId;

    const ownerHalls = await Hall.find({ owner: ownerId });
    const hallIds = ownerHalls.map((h) => h._id);

    const bookings = await Booking.find({
      hall: { $in: hallIds },
    });

    const totalBookings = bookings.length;
    const activeBookings = bookings.filter((b) => !b.isCancelled).length;
    const cancelledBookings = bookings.filter((b) => b.isCancelled).length;
    const totalRevenue = bookings
      .filter((b) => !b.isCancelled)
      .reduce((sum, b) => sum + b.amount, 0);

    res.json({
      totalBookings,
      activeBookings,
      cancelledBookings,
      totalRevenue,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= GET BOOKING BY ID ================= */
router.get("/:id", authMiddleware, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate("hall")
      .populate("user", "name email");

    if (!booking) {
      return res.status(404).json({
        error: "Booking not found",
      });
    }

    // Check if user owns this booking or is an admin
    const User = require("../models/User");
    const user = await User.findById(req.userId);
    
    if (booking.user._id.toString() !== req.userId && user?.role !== "admin") {
      return res.status(403).json({
        error: "Unauthorized - you can only view your own bookings",
      });
    }

    res.json(booking);
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/* ================= VERIFY PAYMENT & UPDATE BOOKING ================= */
router.post("/:bookingId/verify-payment", authMiddleware, async (req, res) => {
  try {
    const { bookingId, paymentId, orderId, signature } = req.body;

    console.log("\n💳 === PAYMENT VERIFICATION ===");
    console.log("Booking ID:", bookingId);
    console.log("Payment ID:", paymentId);
    console.log("Order ID:", orderId);

    // ✅ Step 1: Validate input
    if (!bookingId || !paymentId) {
      return res.status(400).json({
        success: false,
        message: "Booking ID and Payment ID required",
      });
    }

    // ✅ Step 2: Find booking
    const booking = await Booking.findById(bookingId).populate("hall");

    if (!booking) {
      console.log("❌ Booking not found:", bookingId);
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    // ✅ Step 3: Verify user owns this booking or is admin
    const User = require("../models/User");
    const user = await User.findById(req.userId);

    if (booking.user.toString() !== req.userId && user?.role !== "admin") {
      console.log("❌ Unauthorized access - User:", req.userId, "Booking owner:", booking.user);
      return res.status(403).json({
        success: false,
        message: "Unauthorized to verify this payment",
      });
    }

    // ✅ Step 4: Verify Razorpay signature (if signature provided)
    if (signature) {
      const body = orderId + "|" + paymentId;
      const expectedSignature = crypto
        .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
        .update(body)
        .digest("hex");

      if (expectedSignature !== signature) {
        console.log("❌ Signature mismatch");
        return res.status(400).json({
          success: false,
          message: "Invalid payment signature",
        });
      }
      console.log("✅ Signature verified");
    }

    // ✅ Step 5: Update booking with payment details
    booking.paymentId = paymentId;
    booking.orderId = orderId;
    booking.paymentStatus = "paid";
    booking.bookingStatus = "confirmed";
    booking.transactionComplete = true;

    await booking.save();
    console.log("✅ Booking updated with payment details");

    // ✅ Step 6: Create notification for admin
    const notification = new Notification({
      userId: booking.user,
      title: "Payment Confirmed",
      message: `Your payment for ${booking.hall.name} on ${booking.date.toDateString()} has been confirmed.`,
      type: "booking",
      relatedId: booking._id,
      isRead: false,
    });

    await notification.save();
    console.log("✅ Notification created");

    // ✅ Step 7: Return success response
    console.log("✅ Payment verification complete\n");

    return res.status(200).json({
      success: true,
      message: "Payment verified and booking confirmed",
      booking: {
        _id: booking._id,
        hallName: booking.hall.name,
        date: booking.date,
        amount: booking.totalAmount,
        paymentStatus: booking.paymentStatus,
        bookingStatus: booking.bookingStatus,
      },
    });
  } catch (error) {
    console.error("❌ Payment verification error:", error);
    return res.status(500).json({
      success: false,
      message: "Payment verification failed",
      error: error.message,
    });
  }
});

module.exports = router;
