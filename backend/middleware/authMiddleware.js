const jwt = require("jsonwebtoken");

// ✅ CRITICAL: USE CONSISTENT secret everywhere - MUST MATCH rbacMiddleware.js
const SECRET = "wedding_hall_super_secret_key_2024";

/**
 * ✅ FIX: MAIN AUTH MIDDLEWARE
 * - Validates JWT token from Authorization header
 * - Extracts userId and role from token
 * - Sets req.userId and req.userRole for downstream middleware
 * - LOGS ALL STEPS for debugging
 */
module.exports = function authMiddleware(req, res, next) {
  console.log("\n🔐 AUTH MIDDLEWARE VALIDATION:");
  
  const authHeader = req.headers.authorization;
  console.log(`  📋 Auth Header: ${authHeader ? `${authHeader.substring(0, 40)}...` : "MISSING"}`);

  // ✅ Check if header exists
  if (!authHeader) {
    console.log("  ❌ ERROR: Authorization header is missing");
    console.log("  💡 Expected format: Authorization: Bearer <token>");
    return res.status(401).json({ 
      message: "No authorization token provided",
      error: "MISSING_TOKEN",
      expected: "Authorization: Bearer <token>"
    });
  }

  // ✅ Extract "Bearer <token>" format
  let token = authHeader;
  if (authHeader.startsWith("Bearer ")) {
    token = authHeader.substring(7);
    console.log(`  ✓ Bearer prefix found, extracted token`);
  } else {
    console.log(`  ⚠️ WARNING: Auth header doesn't start with 'Bearer '`);
  }
  
  console.log(`  🔑 Token: ${token ? token.substring(0, 20) + "..." : "MISSING"}`);

  // ✅ Verify token is not empty
  if (!token || token.trim() === "") {
    console.log("  ❌ ERROR: Token is empty after parsing");
    return res.status(401).json({ 
      message: "Invalid token format - token is empty",
      error: "EMPTY_TOKEN"
    });
  }

  // ✅ Verify JWT signature and expiry
  try {
    const decoded = jwt.verify(token, SECRET);
    
    console.log(`  ✅ Token verified successfully`);
    console.log(`  👤 User ID: ${decoded.id}`);
    console.log(`  👥 User Role: ${decoded.role || "MISSING"}`);
    if (decoded.exp) {
      const expiryDate = new Date(decoded.exp * 1000);
      console.log(`  ⏰ Expires: ${expiryDate.toISOString()}`);
    }
    
    // ✅ Set on request object for downstream middleware
    req.userId = decoded.id;
    req.userRole = decoded.role || "user"; // Default to user if not specified
    
    console.log(`  ✅ Request object updated: req.userId = ${req.userId}, req.userRole = ${req.userRole}`);
    
    next();
  } catch (error) {
    console.log(`  ❌ Token verification FAILED: ${error.message}`);
    console.log(`  🔍 Error type: ${error.name}`);
    
    let errorCode = "INVALID_TOKEN";
    let statusCode = 401;
    let message = "Invalid token";
    
    if (error.name === "TokenExpiredError") {
      errorCode = "TOKEN_EXPIRED";
      message = "Token has expired. Please login again.";
      console.log(`  ⏰ Token expired at: ${new Date(error.expiredAt).toISOString()}`);
    } else if (error.name === "JsonWebTokenError") {
      errorCode = "MALFORMED_TOKEN";
      message = "Token is malformed or invalid";
    } else if (error.name === "NotBeforeError") {
      errorCode = "TOKEN_NOT_ACTIVE";
      message = "Token is not yet active";
    }
    
    return res.status(statusCode).json({ 
      message,
      error: errorCode,
      details: error.message,
      secret_used: "wedding_hall_super_secret_key_2024"
    });
  }
};
