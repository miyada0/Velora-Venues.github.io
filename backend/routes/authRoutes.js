const express = require("express");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const User = require("../models/User");
const authMiddleware = require("../middleware/authMiddleware");

// ✅ FIX: Use CONSISTENT secret - MUST MATCH both middleware files
const SECRET = "wedding_hall_super_secret_key_2024";

/* ================= SIGNUP ================= */
router.post("/signup", async (req, res) => {
  try {
    console.log("SIGNUP HIT:", req.body);

    const { name, email, password, role: requestedRole } = req.body;

    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({
        message: "Email already exists",
      });
    }

    const hashed = await bcrypt.hash(password, 10);

    // ✅ FIX: ALLOW ROLE ASSIGNMENT - Check admin email first, then use requested role
    let role = "user"; // Default role
    
    if (email === "admin123@test.com") {
      role = "admin";
      console.log("✅ ADMIN EMAIL DETECTED - Creating admin account");
    } else if (requestedRole === "owner") {
      // ✅ Allow owner role if explicitly requested
      role = "owner";
      console.log(`✅ OWNER ROLE REQUESTED - Creating owner account for ${email}`);
    } else if (requestedRole === "user") {
      role = "user";
    } else {
      // Ignore invalid role requests, default to user
      console.log(`⚠️ Invalid role requested: ${requestedRole}, defaulting to user`);
    }

    const user = await User.create({
      name,
      email,
      password: hashed,
      role: role,
    });

    console.log(`📝 User created - ID: ${user._id}, Email: ${user.email}, Role: ${user.role}`);

    const token = jwt.sign(
      { id: user._id, role: user.role },
      SECRET,
      { expiresIn: "7d" }
    );

    res.json({ token, user });

  } catch (error) {
    console.log("SIGNUP ERROR:", error);
    res.status(500).json({ error: error.message });
  }
});

/* ================= LOGIN ================= */
router.post("/login", async (req, res) => {
  try {
    console.log("LOGIN HIT:", req.body);

    const { email, password } = req.body;

    const user = await User.findOne({ email });
    console.log("USER:", user);

    if (!user) {
      return res.status(400).json({
        message: "User not found",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    console.log("MATCH:", isMatch);

    if (!isMatch) {
      return res.status(400).json({
        message: "Invalid password",
      });
    }

    // ✅ FIX: ENSURE ADMIN EMAIL IS ALWAYS ADMIN
    if (email === "admin123@test.com" && user.role !== "admin") {
      user.role = "admin";
      await user.save();
      console.log("✅ ADMIN EMAIL DETECTED - Role set to admin");
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      SECRET,
      { expiresIn: "7d" }
    );

    console.log("📋 LOGIN RESPONSE:");
    console.log("   Email: " + user.email);
    console.log("   Role: " + user.role);
    console.log("   UserId: " + user._id);
    console.log("   Token: " + token.substring(0, 20) + "...");

    res.json({ token, user });

  } catch (error) {
    console.log("LOGIN ERROR:", error);
    res.status(500).json({ error: error.message });
  }
});

/* ================= GET PROFILE ================= */
router.get("/me", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId)
      .select("-password");

    res.json({ user });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= UPDATE PROFILE ================= */
router.put("/update-profile", authMiddleware, async (req, res) => {
  try {
    const { name, email } = req.body;

    const user = await User.findByIdAndUpdate(
      req.userId,
      { name, email },
      { new: true }
    ).select("-password");

    res.json({
      message: "Profile updated",
      user,
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= BLOCK USER ================= */
router.put("/block/:id", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    user.isBlocked = !user.isBlocked;
    await user.save();

    res.json({ message: "User updated" });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* ================= DELETE USER ================= */
router.delete("/:id", authMiddleware, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);

    res.json({ message: "User deleted" });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;