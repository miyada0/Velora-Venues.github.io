const authMiddleware = require("./authMiddleware");

/**
 * ✅ FIX: ROLE-BASED ACCESS CONTROL (RBAC) MIDDLEWARE
 * - Uses consolidated authMiddleware
 * - Provides specific role-checking middlewares
 * - Logs permission checks for debugging
 */

/// ============ ADMIN ONLY ============
/// Only users with role === "admin" can access
const adminOnly = (req, res, next) => {
  console.log("\n🔐 ADMIN_ONLY CHECK:");
  console.log(`  👥 User Role: ${req.userRole}`);
  
  if (req.userRole !== "admin") {
    console.log(`  ❌ DENIED: User is '${req.userRole}', not 'admin'`);
    return res.status(403).json({ 
      message: "Access denied - admin role required",
      error: "ADMIN_REQUIRED",
      userRole: req.userRole
    });
  }
  
  console.log(`  ✅ ALLOWED: User is admin`);
  next();
};

/// ============ OWNER ONLY ============
/// Only users with role === "owner" can access
const ownerOnly = (req, res, next) => {
  console.log("\n🔐 OWNER_ONLY CHECK:");
  console.log(`  👥 User Role: ${req.userRole}`);
  
  if (req.userRole !== "owner") {
    console.log(`  ❌ DENIED: User is '${req.userRole}', not 'owner'`);
    return res.status(403).json({ 
      message: "Access denied - owner role required to register halls",
      error: "OWNER_REQUIRED",
      userRole: req.userRole
    });
  }
  
  console.log(`  ✅ ALLOWED: User is owner`);
  next();
};

/// ============ USER ONLY ============
/// Only users with role === "user" can access (blocks admin/owner)
const userOnly = (req, res, next) => {
  console.log("\n🔐 USER_ONLY CHECK:");
  console.log(`  👥 User Role: ${req.userRole}`);
  
  if (req.userRole !== "user") {
    console.log(`  ❌ DENIED: User is '${req.userRole}', not 'user'`);
    const message = req.userRole === "admin" 
      ? "Admins cannot perform this action"
      : "Owners cannot perform this action";
    
    return res.status(403).json({ 
      message,
      error: "USER_REQUIRED",
      userRole: req.userRole
    });
  }
  
  console.log(`  ✅ ALLOWED: User is regular user`);
  next();
};

/// ============ NOT ADMIN ============
/// Admins cannot access (but owner/user can)
const notAdmin = (req, res, next) => {
  console.log("\n🔐 NOT_ADMIN CHECK:");
  console.log(`  👥 User Role: ${req.userRole}`);
  
  if (req.userRole === "admin") {
    console.log(`  ❌ DENIED: Admins cannot perform this action`);
    return res.status(403).json({ 
      message: "Admins cannot perform this action",
      error: "ADMIN_CANNOT_ACCESS",
      userRole: req.userRole
    });
  }
  
  console.log(`  ✅ ALLOWED: User is not admin`);
  next();
};

/// ============ NOT OWNER ============
/// Owners cannot access (but admin/user can)
const notOwner = (req, res, next) => {
  console.log("\n🔐 NOT_OWNER CHECK:");
  console.log(`  👥 User Role: ${req.userRole}`);
  
  if (req.userRole === "owner") {
    console.log(`  ❌ DENIED: Owners cannot perform this action`);
    return res.status(403).json({ 
      message: "Owners cannot perform this action",
      error: "OWNER_CANNOT_ACCESS",
      userRole: req.userRole
    });
  }
  
  console.log(`  ✅ ALLOWED: User is not owner`);
  next();
};

module.exports = {
  authMiddleware, // Import from authMiddleware.js
  adminOnly,
  ownerOnly,
  userOnly,
  notAdmin,
  notOwner,
};
