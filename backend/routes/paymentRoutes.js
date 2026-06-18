const express = require("express");
const router = express.Router();
const Razorpay = require("razorpay");
const crypto = require("crypto");

/* ================= RAZORPAY INSTANCE (SECURE) ================= */

// ✅ Load keys from environment variables
const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID;
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET;

// 🔴 Validate keys are loaded
if (!RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET) {
  console.error("❌ FATAL: Razorpay keys missing in .env file!");
  console.error("   - Check .env file exists");
  console.error("   - Verify RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET are set");
  process.exit(1);
}

// ✅ Initialize Razorpay with environment keys
const razorpay = new Razorpay({
  key_id: RAZORPAY_KEY_ID,
  key_secret: RAZORPAY_KEY_SECRET,
});

console.log("✅ Payment Routes: Razorpay initialized");
console.log("   Key ID:", RAZORPAY_KEY_ID);
console.log("   Key Secret: (length=" + RAZORPAY_KEY_SECRET.length + " chars)");

/* ================= CREATE ORDER ================= */

router.post("/create-order", async (req, res) => {
  try {
    const { amount } = req.body;

    // ✅ VALIDATION
    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        error: "Valid amount is required",
      });
    }

    console.log("\n💳 CREATE ORDER REQUEST - Amount:", amount, "INR");

    // ✅ CREATE ORDER
    const options = {
      amount: parseInt(amount) * 100, // convert ₹ to paise
      currency: "INR",
      receipt: "receipt_" + Math.random().toString(36).substring(2, 15),
    };

    const order = await razorpay.orders.create(options);

    console.log("✅ Order created: ID =", order.id);

    res.status(200).json({
      success: true,
      order: {
        id: order.id,
        amount: order.amount,
        currency: order.currency,
        receipt: order.receipt,
      },
    });
  } catch (error) {
    // 🔴 COMPREHENSIVE ERROR LOGGING
    console.error("\n❌ === RAZORPAY ORDER CREATION FAILED ===");
    console.error("Error Code:", error.code);
    console.error("Error Message:", error.message);
    console.error("Status Code:", error.statusCode);
    
    if (error.error) {
      console.error("API Error Description:", error.error.description);
    }

    // 🔍 DEBUG: Check if it's an auth error
    if (error.statusCode === 401) {
      console.error("\n🔐 AUTHENTICATION ERROR - Debugging Steps:");
      console.error("   1. Check RAZORPAY_KEY_ID in .env: ", RAZORPAY_KEY_ID || "❌ MISSING");
      console.error("   2. Check RAZORPAY_KEY_SECRET in .env: ", RAZORPAY_KEY_SECRET ? "✅ SET" : "❌ MISSING");
      console.error("   3. Verify keys are from SAME Razorpay account");
      console.error("   4. Check for no extra spaces in .env file");
      console.error("   5. Verify keys are not expired/disabled in dashboard");
    }

    res.status(error.statusCode || 500).json({
      success: false,
      error: error.error?.description || error.message || "Failed to create order",
      code: error.code,
      debug: process.env.NODE_ENV === "development" ? {
        message: error.message,
        code: error.code,
        statusCode: error.statusCode,
      } : undefined,
    });
  }
});

/* ================= VERIFY PAYMENT ================= */

router.post("/verify-payment", async (req, res) => {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
    } = req.body;

    // ✅ VALIDATION
    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({
        success: false,
        error: "Missing payment details",
      });
    }

    console.log("\n🔐 VERIFYING PAYMENT");
    console.log("   Order ID:", razorpay_order_id);
    console.log("   Payment ID:", razorpay_payment_id);

    // ✅ VERIFY SIGNATURE
    const body = razorpay_order_id + "|" + razorpay_payment_id;

    const expectedSignature = crypto
      .createHmac("sha256", RAZORPAY_KEY_SECRET)
      .update(body)
      .digest("hex");

    if (expectedSignature === razorpay_signature) {
      console.log("✅ Payment signature verified successfully");
      return res.status(200).json({
        success: true,
        message: "Payment verified successfully",
        orderId: razorpay_order_id,
        paymentId: razorpay_payment_id,
      });
    } else {
      console.error("❌ Signature mismatch - Payment not authentic!");
      return res.status(400).json({
        success: false,
        error: "Invalid payment signature",
      });
    }
  } catch (error) {
    console.error("Verification error:", error.message);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/* ================= DEBUG ENDPOINT (FOR TESTING ONLY) ================= */

router.get("/debug", (req, res) => {
  if (process.env.NODE_ENV !== "development") {
    return res.status(403).json({ error: "Not available in production" });
  }

  res.json({
    razorpayKeyIdLoaded: !!RAZORPAY_KEY_ID,
    razorpayKeySecretLoaded: !!RAZORPAY_KEY_SECRET,
    keyIdValue: RAZORPAY_KEY_ID || "❌ MISSING",
    keySecretLength: RAZORPAY_KEY_SECRET?.length || 0,
    envVarsLoaded: {
      RAZORPAY_KEY_ID: process.env.RAZORPAY_KEY_ID ? "✅ SET" : "❌ MISSING",
      RAZORPAY_KEY_SECRET: process.env.RAZORPAY_KEY_SECRET ? "✅ SET" : "❌ MISSING",
    },
    nodeEnv: process.env.NODE_ENV,
  });
});

module.exports = router;