require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");

/* ================= CREATE APP ================= */

const app = express();
const server = http.createServer(app);

/* ================= SOCKET.IO ================= */

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

/* ================= MIDDLEWARE ================= */

app.use(cors());
app.use(express.json());

// ✅ TEMPORARILY DISABLED - Null-safety middleware can be re-enabled later if needed
// app.use(require("./middleware/nullSafetyMiddleware"));

/* ================= DATABASE ================= */

mongoose
  .connect("mongodb://127.0.0.1:27017/wedding_app")
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.log("MongoDB Error:", err));

/* ================= STATIC FILES ================= */
/* Allows image loading like http://IP:5000/uploads/image.jpg */

app.use("/uploads", express.static("uploads"));

/* ================= ROUTES ================= */

const authRoutes = require("./routes/authRoutes");
const hallRoutes = require("./routes/hallRoutes");
const bookingRoutes = require("./routes/bookingRoutes");
const reviewRoutes = require("./routes/reviewRoutes");
const adminRoutes = require("./routes/adminRoutes");
const notificationRoutes = require("./routes/NotificationRoutes");
const wishlistRoutes = require("./routes/WishlistRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const ratingRoutes = require("./routes/ratingRoutes");
const analyticsRoutes = require("./routes/analyticsRoutes");

app.use("/api/auth", authRoutes);
app.use("/api/halls", hallRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/wishlist", wishlistRoutes);
app.use("/api/reviews", reviewRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/payment", paymentRoutes);
app.use("/api/ratings", ratingRoutes);
app.use("/api/analytics", analyticsRoutes);

/* ================= ROOT TEST ================= */

app.get("/", (req, res) => {
  res.send("🚀 Wedding Hall API Running");
});

/* ================= SOCKET CHAT ================= */

const Message = require("./models/Message");

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  socket.on("sendMessage", async (data) => {
    try {
      const { senderId, hallId, message } = data;

      const savedMessage = await Message.create({
        sender: senderId,
        hall: hallId,
        message,
      });

      io.emit("receiveMessage", savedMessage);
    } catch (error) {
      console.log("Socket Error:", error);
    }
  });

  socket.on("disconnect", () => {
    console.log("User disconnected");
  });
});

/* ================= START SERVER ================= */

const PORT = 5000;

server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});