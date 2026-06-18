const Razorpay = require("razorpay");

// ✅ Load keys from environment variables
const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID;
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET;

// 🔴 Validate keys are loaded
if (!RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET) {
  console.error("❌ FATAL: Razorpay keys missing in .env file!");
  process.exit(1);
}

const razorpay = new Razorpay({
  key_id: RAZORPAY_KEY_ID,
  key_secret: RAZORPAY_KEY_SECRET,
});

console.log("✅ Payment Controller: Razorpay initialized with Key ID:", RAZORPAY_KEY_ID);

exports.createOrder = async (req, res) => {
  try {
    console.log("\n📋 === CREATE ORDER REQUEST ===");
    
    const { amount } = req.body;

    // ✅ VALIDATION
    if (!amount || amount <= 0) {
      console.error("❌ Invalid amount:", amount);
      return res.status(400).json({
        success: false,
        error: "Valid amount is required",
      });
    }

    console.log("💰 Amount (INR):", amount);
    console.log("🔑 Key ID loaded:", !!RAZORPAY_KEY_ID);
    console.log("🔑 Key ID preview:", RAZORPAY_KEY_ID?.substring(0, 20) + "...");
    console.log("🔐 Secret loaded:", !!RAZORPAY_KEY_SECRET);

    // ✅ CREATE ORDER
    const options = {
      amount: parseInt(amount) * 100, // convert ₹ to paise
      currency: "INR",
      receipt: "receipt_" + Math.random().toString(36).substring(2, 15),
    };

    console.log("📝 Creating Razorpay order with options:", options);

    const order = await razorpay.orders.create(options);

    console.log("✅ Order created successfully!");
    console.log("   Order ID:", order.id);
    console.log("   Amount:", order.amount, "paise");
    console.log("   Status:", order.status);

    res.status(200).json({
      success: true,
      order: {
        id: order.id,
        amount: order.amount,
        currency: order.currency,
      },
    });
  } catch (error) {
    console.error("\n❌ === RAZORPAY ORDER CREATION FAILED ===");
    console.error("Error Type:", error.name || "Unknown");
    console.error("Error Code:", error.code);
    console.error("Error Message:", error.message);
    console.error("Status Code:", error.statusCode);
    
    if (error.error) {
      console.error("API Error Response:", JSON.stringify(error.error, null, 2));
    }
    
    // 🔍 Specific auth error debugging
    if (error.statusCode === 401) {
      console.error("\n🔐 AUTHENTICATION FAILED - Checking configuration:");
      console.error("   ✓ RAZORPAY_KEY_ID:", RAZORPAY_KEY_ID ? RAZORPAY_KEY_ID.substring(0, 20) + "..." : "❌ MISSING");
      console.error("   ✓ RAZORPAY_KEY_SECRET:", RAZORPAY_KEY_SECRET ? "SET (" + RAZORPAY_KEY_SECRET.length + " chars)" : "❌ MISSING");
      console.error("   → Verify keys in .env file are from same Razorpay account");
      console.error("   → Check for extra spaces in .env values");
    }

    console.error("\nFull Error Object:", JSON.stringify(error, null, 2));

    res.status(error.statusCode || 500).json({
      success: false,
      error: error.error?.description || error.message || "Failed to create order",
      code: error.code,
      statusCode: error.statusCode,
      debug: process.env.NODE_ENV === "development" ? {
        message: error.message,
        code: error.code,
        statusCode: error.statusCode,
        errorDetails: error.error,
      } : undefined,
    });
  }
};