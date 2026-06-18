const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const User = require("./models/User");

mongoose
  .connect("mongodb://127.0.0.1:27017/wedding_app")
  .then(async () => {
    console.log("✅ MongoDB Connected");

    try {
      // Check if admin already exists
      const existingAdmin = await User.findOne({ email: "admin123@test.com" });

      if (existingAdmin) {
        console.log("✅ Admin user already exists");
        process.exit(0);
      }

      // Create admin user
      const hashedPassword = await bcrypt.hash("mypassword", 10);

      const admin = await User.create({
        name: "Admin",
        email: "admin123@test.com",
        password: hashedPassword,
        role: "admin",
      });

      console.log("✅ Admin user created successfully");
      console.log("📧 Email: admin123@test.com");
      console.log("🔐 Password: mypassword");
      console.log("👤 Admin ID: " + admin._id);

      process.exit(0);
    } catch (error) {
      console.error("❌ Error creating admin:", error.message);
      process.exit(1);
    }
  })
  .catch((err) => {
    console.log("❌ MongoDB Error:", err);
    process.exit(1);
  });
