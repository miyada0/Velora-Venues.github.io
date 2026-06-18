# 🔧 QUICK FIX REFERENCE - Auth System

## ⚡ ONE-LINE SUMMARY
**JWT secret mismatch was allowing different middleware to reject tokens from different middleware, causing 401 cascade. Fixed by unifying secrets across all files.**

---

## 🔑 THE CRITICAL FIX

### Before (BROKEN ❌):
```javascript
// authMiddleware.js
const SECRET = "secret";

// rbacMiddleware.js  
const SECRET = process.env.JWT_SECRET || "secret_key";  // Different!

// authRoutes.js
jwt.sign({ ... }, "secret", ...)
```

### After (WORKING ✅):
```javascript
// authMiddleware.js
const SECRET = "wedding_hall_super_secret_key_2024";

// rbacMiddleware.js
const SECRET = "wedding_hall_super_secret_key_2024";  // SAME!

// authRoutes.js
jwt.sign({ ... }, SECRET, ...)
```

---

## 📋 EXACT CHANGES MADE

### Backend:

1. **authMiddleware.js** - Line 3:
   ```javascript
   // ✅ FIX: Use CONSISTENT secret everywhere
   const SECRET = "wedding_hall_super_secret_key_2024";
   ```

2. **rbacMiddleware.js** - Line 1-4:
   ```javascript
   const jwt = require("jsonwebtoken");
   
   // ✅ FIX: Use CONSISTENT secret
   const SECRET = "wedding_hall_super_secret_key_2024";
   ```

3. **authRoutes.js** - Added SECRET at top, changed jwt.sign calls:
   ```javascript
   const SECRET = "wedding_hall_super_secret_key_2024";
   
   // Change:  jwt.sign({...}, "secret", ...)
   // To:      jwt.sign({...}, SECRET, ...)
   ```

4. **WishlistRoutes.js** - Line 4:
   ```javascript
   // Changed: const authMiddleware = require("../middleware/authMiddleware");
   // To:      const { authMiddleware } = require("../middleware/rbacMiddleware");
   ```

5. **reviewRoutes.js** - Line 8:
   ```javascript
   // Changed: const authMiddleware = require("../middleware/authMiddleware");
   // To:      const { authMiddleware } = require("../middleware/rbacMiddleware");
   ```

6. **NotificationRoutes.js** - Line 4:
   ```javascript
   // Changed: const authMiddleware = require("../middleware/authMiddleware");
   // To:      const { authMiddleware } = require("../middleware/rbacMiddleware");
   ```

7. **hallRoutes.js** - Line ~65:
   ```javascript
   // Changed: router.get("/my", require("../middleware/authMiddleware"), async (req, res) => {
   // To:      router.get("/my", authMiddleware, async (req, res) => {
   ```

8. **server.js** - Added middleware:
   ```javascript
   // Add after express.json():
   app.use(require("./middleware/nullSafetyMiddleware"));
   ```

### Flutter:

1. **api_service.dart** - Added:
   ```dart
   // Global logout callback
   static OnLogoutCallback? _onLogoutCallback;
   static bool _isProcessingLogout = false;
   
   // Security: Don't logout on login/signup 401s
   if (!e.requestOptions.path.contains("/auth/login") &&
       !e.requestOptions.path.contains("/auth/signup")) {
     _handleUnauthorized();
   }
   
   // RetryInterceptor: Don't retry 401 or auth endpoints
   if (err.response?.statusCode == 401) return false;
   if (err.requestOptions.path.contains("/auth/login")) return false;
   ```

2. **auth_service.dart** - Added delays:
   ```dart
   // After token save, add small delay
   await Future.delayed(const Duration(milliseconds: 200));
   ```

3. **auth_vm.dart** - Register callback:
   ```dart
   // In constructor:
   ApiService.setOnLogoutCallback(_performLogout);
   
   // Move logout logic to _performLogout()
   ```

---

## ✅ WHAT'S NOW FIXED

| Problem | Root Cause | Solution |
|---------|-----------|----------|
| Login works, then 401 | Token verification mismatch | Unified JWT secret |
| Wishlist fails 401 | Token signed with "secret", verified with "secret_key" | All use same secret |
| Bookings fail 401 | Different middleware, different secrets | Use rbacMiddleware everywhere |
| Auto-logout cascade | Any 401 triggered logout, causing more 401s | Added `_isProcessingLogout` flag |
| Null type errors | Backend returning null for numbers | Added nullSafetyMiddleware |
| Token lost on navigation | Race condition in token save | Added 200ms delay |

---

## 🚀 HOW TO DEPLOY

1. **Backend:** Restart Node server
2. **Frontend:** Run `flutter pub get` (if needed) and hot-restart app
3. **Test:** Login and check console for token messages

---

## 🔍 HOW TO VERIFY IT WORKS

Run these commands to see the flow:

**Terminal 1 - Backend:**
```bash
cd backend
node server.js
# Watch for: ✅ MongoDB Connected, 🚀 Server running on port 5000
```

**Terminal 2 - Flutter Developer Console:**
Open DevTools and watch the console. After login, you should see:
```
🔄 AUTH SERVICE: Sending login request...
✅ Token saved to storage and headers
[After 200ms delay, navigation happens]
➡️ GET /halls
🔐 Token added (...)
✅ 200 /halls
```

If you see this sequence, **Auth is FIXED ✓**

---

## 🎯 REMEMBER

- **Secret Key:** `wedding_hall_super_secret_key_2024`
- **Change before production!**
- **Use environment variables in production**
- **All files must use the SAME secret**

---

## ⚠️ IF SOMETHING BREAKS

1. Check all three files have the SAME SECRET
2. Restart backend + app
3. Clear app cache: `flutter clean`
4. Rebuild: `flutter pub get`
5. Check console for error messages
6. Verify backend is running before starting app
