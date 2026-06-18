const express = require("express");
const router = express.Router();

const Hall = require("../models/hall");
const {
  authMiddleware,
  notAdmin,
} = require("../middleware/rbacMiddleware");

/* ================= CREATE HALL ================= */

router.post("/", authMiddleware, async (req, res) => {
  try {
    // ✅ DEBUG: Log user info
    console.log("\n🏛️ CREATE HALL REQUEST:");
    console.log("  📝 Request Body:", req.body);
    console.log("  👤 User ID:", req.userId);
    console.log("  👥 User Role:", req.userRole);
    
    const {
      name,
      location,
      price,
      rating,
      images,
      facilities,
      capacity,
      description,
    } = req.body;

    const hall = await Hall.create({
      name,
      location,
      price,
      rating,
      images,
      facilities,
      capacity,
      description,
      owner: req.userId,
      status: "pending",
    });

    console.log("✅ Hall created successfully - ID:", hall._id);

    res.json({
      message: "Hall submitted for approval",
      hall,
    });

  } catch (error) {
    console.error("❌ CREATE HALL ERROR:", error);
    res.status(500).json({ error: error.message });
  }
});

/* ================= GET ALL HALLS ================= */

router.get("/", async (req, res) => {
  try {
    /// ✅ BUILD FILTER QUERY FOR APPROVED HALLS
    const query = { status: "approved" };

    /// ✅ PRICE FILTER: price between minPrice and maxPrice
    if (req.query.minPrice || req.query.maxPrice) {
      query.price = {};
      
      if (req.query.minPrice) {
        const minPrice = parseFloat(req.query.minPrice);
        if (!isNaN(minPrice)) {
          query.price.$gte = minPrice;
        }
      }
      
      if (req.query.maxPrice) {
        const maxPrice = parseFloat(req.query.maxPrice);
        if (!isNaN(maxPrice)) {
          query.price.$lte = maxPrice;
        }
      }
    }

    /// ✅ RATING FILTER: rating range between minRating and maxRating
    if (req.query.minRating || req.query.maxRating) {
      query.rating = {};
      
      if (req.query.minRating) {
        const minRating = parseFloat(req.query.minRating);
        if (!isNaN(minRating)) {
          query.rating.$gte = minRating;
        }
      }
      
      if (req.query.maxRating) {
        const maxRating = parseFloat(req.query.maxRating);
        if (!isNaN(maxRating)) {
          query.rating.$lte = maxRating;
        }
      }
    }

    /// ✅ CAPACITY FILTER: capacity range between minCapacity and maxCapacity
    if (req.query.minCapacity || req.query.maxCapacity) {
      query.capacity = {};
      
      if (req.query.minCapacity) {
        const minCapacity = parseFloat(req.query.minCapacity);
        if (!isNaN(minCapacity)) {
          query.capacity.$gte = minCapacity;
        }
      }
      
      if (req.query.maxCapacity) {
        const maxCapacity = parseFloat(req.query.maxCapacity);
        if (!isNaN(maxCapacity)) {
          query.capacity.$lte = maxCapacity;
        }
      }
    }

    /// ✅ LOCATION FILTER: case-insensitive substring search
    if (req.query.locations && req.query.locations.trim()) {
      const locationList = req.query.locations.split(",").map(l => l.trim());
      if (locationList.length > 0) {
        query.location = {
          $in: locationList.map(loc => new RegExp(loc, "i"))
        };
      }
    }

    /// ✅ FACILITIES FILTER: hall must have ALL selected facilities
    if (req.query.facilities && req.query.facilities.trim()) {
      const facilitiesList = req.query.facilities
        .split(",")
        .map(f => f.trim())
        .filter(f => f.length > 0);
      
      if (facilitiesList.length > 0) {
        // MongoDB $all operator: document array must contain ALL specified values
        query.facilities = { $all: facilitiesList };
      }
    }

    /// ✅ SORTING LOGIC
    let sort = { _id: -1 }; // Default sort by latest
    
    if (req.query.sortBy === "price_low") {
      sort = { price: 1 }; // Low to high
    } else if (req.query.sortBy === "price_high") {
      sort = { price: -1 }; // High to low
    } else if (req.query.sortBy === "rating_high") {
      sort = { rating: -1 }; // Highest rating first
    } else if (req.query.sortBy === "capacity_high") {
      sort = { capacity: -1 }; // Highest capacity first
    }

    /// ✅ EXECUTE QUERY WITH FILTERS AND SORTING
    const halls = await Hall.find(query).sort(sort);

    res.json(halls);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= GET OWNER'S HALLS (My Halls) ================= */

router.get("/my", authMiddleware, async (req, res) => {
  try {
    // ✅ FIX #2: Return halls registered by the owner
    const halls = await Hall.find({ owner: req.userId }).select(
      "_id name location price images status capacity description owner"
    );
    
    res.json(halls);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= OLD ENDPOINT (Keep for compatibility) ================= */

router.get("/owner/halls", authMiddleware, async (req, res) => {
  try {
    const halls = await Hall.find({ owner: req.userId });
    res.json(halls);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= GET SINGLE HALL STATS ================= */

router.get("/owner/stats/:hallId", authMiddleware, async (req, res) => {
  try {
    const { hallId } = req.params;
    
    // Verify ownership
    const hall = await Hall.findById(hallId);
    if (!hall) {
      return res.status(404).json({ error: "Hall not found" });
    }
    
    if (hall.owner.toString() !== req.userId) {
      return res.status(403).json({ error: "Unauthorized" });
    }

    // Get bookings for this hall
    const Booking = require("../models/Booking");
    const bookings = await Booking.find({ hall: hallId });

    const totalBookings = bookings.length;
    const activeBookings = bookings.filter(b => !b.isCancelled).length;
    const cancelledBookings = bookings.filter(b => b.isCancelled).length;
    const totalRevenue = bookings
      .filter(b => !b.isCancelled)
      .reduce((sum, b) => sum + b.amount, 0);

    res.json({
      hall,
      totalBookings,
      activeBookings,
      cancelledBookings,
      totalRevenue,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= GET SINGLE HALL STATS ================= */

router.get("/:id", async (req, res) => {
  try {
    const hall = await Hall.findById(req.params.id);

    res.json(hall);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= DELETE HALL ================= */

router.delete("/:id", authMiddleware, async (req, res) => {
  try {
    const hall = await Hall.findById(req.params.id);

    if (!hall) {
      return res.status(404).json({
        error: "Hall not found",
      });
    }

    // Check ownership
    if (hall.owner.toString() !== req.userId) {
      return res.status(403).json({
        error: "Unauthorized - you can only delete your own halls",
      });
    }

    // Delete associated bookings
    const Booking = require("../models/Booking");
    await Booking.deleteMany({ hall: hall._id });

    // Delete the hall
    await Hall.findByIdAndDelete(req.params.id);

    res.json({
      message: "Hall deleted successfully",
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;