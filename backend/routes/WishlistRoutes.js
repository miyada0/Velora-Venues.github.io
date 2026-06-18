const express = require("express");
const router = express.Router();
const Wishlist = require("../models/Wishlist");
const { authMiddleware } = require("../middleware/rbacMiddleware");

// Add to wishlist
router.post("/", authMiddleware, async (req, res) => {
  try {
    const { hallId } = req.body;
    const userId = req.userId;

    // Validate input
    if (!hallId) {
      return res.status(400).json({ error: "Hall ID is required" });
    }

    // Check if already in wishlist
    const existing = await Wishlist.findOne({
      user: userId,
      hall: hallId,
    });

    if (existing) {
      return res.status(400).json({ message: "Already in wishlist" });
    }

    // Create wishlist entry
    const item = await Wishlist.create({
      user: userId,
      hall: hallId,
    });

    // Populate hall details
    const populatedItem = await Wishlist.findById(item._id).populate({
      path: "hall",
      select: "name location price images capacity facilities description rating owner _id",
    });

    // ✅ FIX: Ensure all fields have default values
    const sanitized = {
      _id: populatedItem._id,
      hall: {
        _id: populatedItem.hall?._id || "",
        name: populatedItem.hall?.name || "Unknown Hall",
        location: populatedItem.hall?.location || "",
        price: populatedItem.hall?.price || 0,
        rating: populatedItem.hall?.rating || 0,
        capacity: populatedItem.hall?.capacity || 0,
        images: populatedItem.hall?.images || [],
        facilities: populatedItem.hall?.facilities || [],
        description: populatedItem.hall?.description || "",
        owner: populatedItem.hall?.owner || null,
      },
      user: populatedItem.user,
      createdAt: populatedItem.createdAt,
      updatedAt: populatedItem.updatedAt,
    };

    res.status(201).json({
      message: "Added to wishlist",
      data: sanitized,
    });
  } catch (e) {
    // Handle duplicate key error
    if (e.code === 11000) {
      return res.status(400).json({ error: "Already in wishlist" });
    }
    console.error("❌ Wishlist POST Error:", e);
    res.status(500).json({ error: e.message });
  }
});

// Get user's wishlist
router.get("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.userId;

    const items = await Wishlist.find({ user: userId }).populate({
      path: "hall",
      select: "name location price images capacity facilities description rating owner _id",
    });

    // ✅ FIX: Ensure all fields have default values
    const sanitizedItems = items.map((item) => ({
      _id: item._id,
      hall: {
        _id: item.hall?._id || "",
        name: item.hall?.name || "Unknown Hall",
        location: item.hall?.location || "",
        price: item.hall?.price || 0,
        rating: item.hall?.rating || 0,
        capacity: item.hall?.capacity || 0,
        images: item.hall?.images || [],
        facilities: item.hall?.facilities || [],
        description: item.hall?.description || "",
        owner: item.hall?.owner || null,
      },
      user: item.user,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    }));

    console.log("✅ Wishlist API Response (sanitized):", JSON.stringify(sanitizedItems, null, 2));

    res.json({
      message: "Wishlist retrieved successfully",
      data: sanitizedItems,
      count: sanitizedItems.length,
    });
  } catch (e) {
    console.error("❌ Wishlist GET Error:", e);
    res.status(500).json({ error: e.message });
  }
});

// Delete from wishlist
router.delete("/:id", authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.userId;

    // Validate input
    if (!id) {
      return res.status(400).json({ error: "Wishlist ID is required" });
    }

    // Find and verify ownership
    const item = await Wishlist.findById(id);

    if (!item) {
      return res.status(404).json({ error: "Wishlist item not found" });
    }

    if (item.user.toString() !== userId) {
      return res.status(403).json({ error: "Unauthorized" });
    }

    // Delete the item
    await Wishlist.findByIdAndDelete(id);

    res.json({ message: "Removed from wishlist" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
