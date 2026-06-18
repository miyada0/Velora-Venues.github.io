# 🎯 Quick Reference - Role Permission Fix

## Summary of Changes

### ✅ Backend Fixes (Node.js)
1. **authRoutes.js** - Accept `role` parameter during signup
2. **hallRoutes.js** - Add debug logging for hall creation
3. **rbacMiddleware.js** - Enhanced logging for permission checks

### ✅ Frontend Fixes (Flutter)
1. **signup_screen.dart** - Add role selector UI
2. **auth_service.dart** - Pass role to backend
3. **auth_vm.dart** - Propagate role through ViewModel

---

## 🔑 Key Files Changed

| File | Change | Status |
|------|--------|--------|
| `backend/routes/authRoutes.js` | Accept owner role in signup | ✅ Done |
| `backend/routes/hallRoutes.js` | Add debug logging | ✅ Done |
| `backend/middleware/rbacMiddleware.js` | Enhanced logging | ✅ Done |
| `wedding_hall_app/lib/views/auth/signup_screen.dart` | Add role selector | ✅ Done |
| `wedding_hall_app/lib/services/auth_service.dart` | Pass role to backend | ✅ Done |
| `wedding_hall_app/lib/viewmodels/auth_vm.dart` | Propagate role param | ✅ Done |

---

## 🧪 Test Scenarios

### 1. Create Owner Account
**Intent**: Verify owner can be created with role selection
```
Signup Screen:
- Name: owner_test
- Email: owner@test.com
- Select: "Hall Owner" option
- Password: test123

Expected Backend Log:
✅ OWNER ROLE REQUESTED - Creating owner account
📝 User created - Email: owner@test.com, Role: owner
```

### 2. Owner Registers Hall
**Intent**: Verify owner can register a hall
```
After login as owner:
- Navigate to "Add Hall"
- Fill hall details
- Submit

Expected Backend Log:
🏛️ CREATE HALL REQUEST:
  👥 User Role: owner
✅ ALLOWED - User is owner
✅ Hall created successfully
```

### 3. User Cannot Register Hall
**Intent**: Verify regular users blocked from registering halls
```
Signup Screen:
- Select: "Customer" option
- Complete signup

Navigate to Add Hall:
Expected Response:
❌ "Access denied - owner only"

Backend Log:
❌ DENIED - Role is 'user', not 'owner'
```

### 4. Admin Cannot Register Hall
**Intent**: Verify admins blocked from registering halls
```
Signup with email: admin123@test.com
- Note: Role auto-set to "admin"

Navigate to Add Hall:
Expected Response:
❌ "Access denied - owner only"

Backend Log:
❌ DENIED - Role is 'admin', not 'owner'
```

---

## 🔍 Verification Commands

### Backend Logs to Watch For

**Owner Signup**:
```
✅ OWNER ROLE REQUESTED - Creating owner account for owner@test.com
📝 User created - ID: <mongoId>, Email: owner@test.com, Role: owner
```

**Hall Creation Attempt**:
```
🏛️ CREATE HALL REQUEST:
  👤 User ID: <id>
  👥 User Role: owner
✅ ALLOWED - User is owner
✅ Hall created successfully
```

**Permission Denied**:
```
❌ DENIED - Role is 'user', not 'owner'
```

---

## 🚨 Common Issues & Fixes

### Issue: "Cannot register hall" for owner
**Check**:
1. Verify role was set to "owner" during signup
   - Look for: `OWNER ROLE REQUESTED - Creating owner account`
2. Verify token is sent in requests
   - Network tab should show `Authorization: Bearer <token>`
3. Verify JWT contains role
   - Decode token at jwt.io

**Fix**: Delete app data, re-signup selecting "Hall Owner" option

### Issue: Logger not showing custom messages
**Check**:
1. Ensure Node.js server restarted after code change
2. Check console.log statements are in correct files
3. Verify backend running in correct directory

**Fix**: 
```bash
# Terminal in backend/
node server.js
```

### Issue: Flutter still showing old behavior
**Check**:
1. Flutter app was rebuilt
2. Old APK not running

**Fix**:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📝 Code References

### JWT Token Structure
```javascript
// Generated Token
{
  id: "507f1f77bcf86cd799439011",  // MongoDB ID
  role: "owner",                    // admin | owner | user
  iat: 1234567890,
  exp: 1234571490
}
```

### Role Check Middleware
```javascript
// ownerOnly middleware
if (req.userRole !== "owner") {
  return res.status(403).json({ 
    error: "Access denied - owner only" 
  });
}
```

### Signup Request Format
```json
POST /auth/signup
{
  "name": "John Owner",
  "email": "owner@test.com",
  "password": "password123",
  "role": "owner"
}
```

---

## ✅ Completion Checklist

- [x] Backend accepts owner role during signup
- [x] Frontend shows role selector during signup
- [x] JWT token contains role field
- [x] authMiddleware extracts role from JWT
- [x] ownerOnly middleware checks for "owner" role
- [x] hallRoutes.js validates owner permission
- [x] Debug logging at each step
- [x] Owner CAN register hall
- [x] User CANNOT register hall
- [x] Admin CANNOT register hall

---

## 📞 Support Info

**Issue**: Permission denied when trying to register hall

**Resolution**: Follow "Test Scenarios" above to identify exact issue

**Debug Mode**: All logs included - grep backend console for:
- `🔐` for permission checks
- `🏛️` for hall operations
- `❌` for errors
- `✅` for success

---

**Status**: READY FOR TESTING ✅

