const express = require("express");
const router = express.Router();
const Booking = require("../models/Booking");
const Hall = require("../models/hall");
const User = require("../models/User");
const Rating = require("../models/Rating");

// ✅ ADMIN ANALYTICS - All system data
router.get("/admin", async (req, res) => {
  try {
    // 1️⃣ Bookings over time (last 30 days, by day)
    const bookingsTrend = await Booking.aggregate([
      {
        $match: {
          createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
          isCancelled: false,
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m-%d", date: "$createdAt" },
          },
          count: { $sum: 1 },
          revenue: { $sum: "$totalAmount" },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // 2️⃣ Revenue by month (last 12 months)
    const revenueTrend = await Booking.aggregate([
      {
        $match: {
          createdAt: { $gte: new Date(Date.now() - 365 * 24 * 60 * 60 * 1000) },
          paymentStatus: "paid",
          isCancelled: false,
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m", date: "$createdAt" },
          },
          totalRevenue: { $sum: "$totalAmount" },
          bookingCount: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // 3️⃣ Top Halls (by booking count)
    const topHalls = await Booking.aggregate([
      {
        $match: {
          isCancelled: false,
        },
      },
      {
        $group: {
          _id: "$hall",
          bookingCount: { $sum: 1 },
          totalRevenue: { $sum: "$totalAmount" },
        },
      },
      { $sort: { bookingCount: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: "halls",
          localField: "_id",
          foreignField: "_id",
          as: "hallDetails",
        },
      },
      {
        $project: {
          hallId: "$_id",
          hallName: { $arrayElemAt: ["$hallDetails.name", 0] },
          bookingCount: 1,
          totalRevenue: 1,
          _id: 0,
        },
      },
    ]);

    // 4️⃣ Average Ratings per Hall
    const ratings = await Rating.aggregate([
      {
        $group: {
          _id: "$hall",
          averageRating: { $avg: "$rating" },
          reviewCount: { $sum: 1 },
        },
      },
      { $sort: { averageRating: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: "halls",
          localField: "_id",
          foreignField: "_id",
          as: "hallDetails",
        },
      },
      {
        $project: {
          hallId: "$_id",
          hallName: { $arrayElemAt: ["$hallDetails.name", 0] },
          averageRating: { $round: ["$averageRating", 1] },
          reviewCount: 1,
          _id: 0,
        },
      },
    ]);

    // 5️⃣ Summary Stats
    const totalBookings = await Booking.countDocuments({ isCancelled: false });
    const totalUsers = await User.countDocuments({ role: "user" });
    const totalHalls = await Hall.countDocuments({ status: "approved" });
    const totalRevenue = await Booking.aggregate([
      {
        $match: {
          paymentStatus: "paid",
          isCancelled: false,
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: "$totalAmount" },
        },
      },
    ]);

    res.json({
      success: true,
      data: {
        bookingsTrend,
        revenueTrend,
        topHalls,
        ratings,
        summary: {
          totalBookings,
          totalUsers,
          totalHalls,
          totalRevenue: totalRevenue[0]?.total || 0,
        },
      },
    });
  } catch (error) {
    console.error("Admin Analytics Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ✅ OWNER ANALYTICS - Only their halls' data
router.get("/owner/:ownerId", async (req, res) => {
  try {
    const { ownerId } = req.params;

    // Get all halls owned by this owner
    const ownerHalls = await Hall.find({ owner: ownerId }).select("_id");
    const hallIds = ownerHalls.map((h) => h._id);

    if (hallIds.length === 0) {
      return res.json({
        success: true,
        data: {
          bookingsTrend: [],
          revenueTrend: [],
          topHalls: [],
          ratings: [],
          summary: {
            totalBookings: 0,
            totalRevenue: 0,
            totalHalls: 0,
          },
        },
      });
    }

    // 1️⃣ Bookings over time for owner's halls
    const bookingsTrend = await Booking.aggregate([
      {
        $match: {
          hall: { $in: hallIds },
          createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
          isCancelled: false,
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m-%d", date: "$createdAt" },
          },
          count: { $sum: 1 },
          revenue: { $sum: "$totalAmount" },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // 2️⃣ Revenue by month for owner's halls
    const revenueTrend = await Booking.aggregate([
      {
        $match: {
          hall: { $in: hallIds },
          createdAt: { $gte: new Date(Date.now() - 365 * 24 * 60 * 60 * 1000) },
          paymentStatus: "paid",
          isCancelled: false,
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m", date: "$createdAt" },
          },
          totalRevenue: { $sum: "$totalAmount" },
          bookingCount: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // 3️⃣ Top halls for this owner
    const topHalls = await Booking.aggregate([
      {
        $match: {
          hall: { $in: hallIds },
          isCancelled: false,
        },
      },
      {
        $group: {
          _id: "$hall",
          bookingCount: { $sum: 1 },
          totalRevenue: { $sum: "$totalAmount" },
        },
      },
      { $sort: { bookingCount: -1 } },
      {
        $lookup: {
          from: "halls",
          localField: "_id",
          foreignField: "_id",
          as: "hallDetails",
        },
      },
      {
        $project: {
          hallId: "$_id",
          hallName: { $arrayElemAt: ["$hallDetails.name", 0] },
          bookingCount: 1,
          totalRevenue: 1,
          _id: 0,
        },
      },
    ]);

    // 4️⃣ Ratings for owner's halls
    const ratings = await Rating.aggregate([
      {
        $match: {
          hall: { $in: hallIds },
        },
      },
      {
        $group: {
          _id: "$hall",
          averageRating: { $avg: "$rating" },
          reviewCount: { $sum: 1 },
        },
      },
      { $sort: { averageRating: -1 } },
      {
        $lookup: {
          from: "halls",
          localField: "_id",
          foreignField: "_id",
          as: "hallDetails",
        },
      },
      {
        $project: {
          hallId: "$_id",
          hallName: { $arrayElemAt: ["$hallDetails.name", 0] },
          averageRating: { $round: ["$averageRating", 1] },
          reviewCount: 1,
          _id: 0,
        },
      },
    ]);

    // 5️⃣ Summary Stats for owner
    const totalBookings = await Booking.countDocuments({
      hall: { $in: hallIds },
      isCancelled: false,
    });

    const totalRevenueResult = await Booking.aggregate([
      {
        $match: {
          hall: { $in: hallIds },
          paymentStatus: "paid",
          isCancelled: false,
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: "$totalAmount" },
        },
      },
    ]);

    res.json({
      success: true,
      data: {
        bookingsTrend,
        revenueTrend,
        topHalls,
        ratings,
        summary: {
          totalBookings,
          totalRevenue: totalRevenueResult[0]?.total || 0,
          totalHalls: hallIds.length,
        },
      },
    });
  } catch (error) {
    console.error("Owner Analytics Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
