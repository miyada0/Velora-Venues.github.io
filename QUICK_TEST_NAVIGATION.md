# 🚀 QUICK START - TEST NAVIGATION FIX

## 1. Clear and Rebuild App

```bash
cd wedding_hall_app
flutter clean
flutter pub get
flutter run
```

---

## 2. EXPECTED: LoginScreen Appears First

When app starts, you should see:
- ✅ LoginScreen with email/password fields
- ❌ NOT AdminDashboard
- ❌ NOT SplashScreen (or very briefly then to login)
- ❌ NOT any dashboard

---

## 3. Test Login as Regular User

```
Email: user@example.com
Password: password123
```

**Check Console Logs For**:
```
🔐 LOGIN SCREEN: Attempting login
🔄 LOGIN REQUEST:
✅ LOGIN SUCCESSFUL
👤 Role: user
📲 Navigating to home for all users
```

**Check UI For**:
- ✅ MainNavigationScreen appears
- ✅ Bottom tabs: Home | Bookings | Profile
- ✅ Home screen showing hall list

---

## 4. Test Login as Admin

```
Email: admin@wedding-hall.com
Password: admin123
```

**Check Console Logs For**:
```
✅ LOGIN SUCCESSFUL
👤 Role: admin
📲 Navigating to home for all users  ← SAME message
```

**Check UI For**:
- ✅ MainNavigationScreen appears (SAME screen as user)
- ✅ Bottom tabs: Dashboard | Profile (DIFFERENT tabs based on role)
- ✅ Dashboard showing admin stats

**KEY POINT**: Same entry screen (MainNavigationScreen), but different tabs shown.

---

## 5. Test Logout

1. Go to Profile tab
2. Find and click "Logout" button
3. Should see: `🔓 LOGOUT: Token cleared`
4. LoginScreen should appear automatically

---

## 6. Test Relaunch After Logout

1. With LoginScreen showing, close app completely
2. Press home button, swipe away app from recent apps
3. Tap app icon to reopen
4. LoginScreen should appear (NOT automatically logged in)

---

## 7. Test Signup as New User

1. On LoginScreen, click "Sign Up" or "Create Account"
2. Fill in details
3. Select role: "user", "owner", or "admin"
4. Click Sign Up

**Check Console**:
```
✅ SIGNUP SUCCESSFUL
👤 Assigned Role: [user/owner/admin]
📲 Navigating to home for all users  ← SAME for all roles
```

**Check UI**: MainNavigationScreen appears with appropriate tabs for chosen role

---

## ✅ Success Indicators

After these 7 tests, you should have:

- ✅ LoginScreen on app start (not dashboard)
- ✅ Regular user sees Home + Bookings tabs after login
- ✅ Admin sees Dashboard + Profile after login
- ✅ Owner sees My Halls + Profile after login
- ✅ Logout -> LoginScreen appears
- ✅ Relaunch -> LoginScreen appears (no auto-login)
- ✅ Console shows "Navigating to home for all users" for all login scenarios

---

## ❌ What SHOULD NOT Happen

- ❌ App starts on AdminDashboard or any dashboard
- ❌ User auto-logs in without entering credentials
- ❌ After login, different users go to different "home" screens
- ❌ Console shows role-based navigation (admin-dashboard, owner-dashboard)

---

## 🐛 If Issues Occur

### Issue: Still shows admin dashboard on startup
**Fix**: 
- [ ] Run `flutter clean && flutter pub get && flutter run`
- [ ] Check auth_vm.dart has `await _authService.logout()` call
- [ ] Check main.dart has correct home logic

### Issue: Auto-logs in old user
**Fix**:
- [ ] Check auth_vm.dart _initAsync() doesn't restore token
- [ ] Check authService.logout() is being called
- [ ] Check SharedPreferences is being cleared

### Issue: Different users go to different pages after login
**Fix**:
- [ ] Check login_screen.dart doesn't have role-based navigation
- [ ] Check it always navigates to "/home"
- [ ] Check signup_screen.dart also navigates to "/home"

---

## 📊 Navigation Summary (Quick Reference)

```
App Start
  ↓
auth == null?
  ├─ YES → LoginScreen
  │         └→ User enters credentials
  │             └→ MainNavigationScreen (same for all)
  │                 ├─ Admin → Dashboard tab
  │                 ├─ Owner → My Halls tab
  │                 └─ User → Home tab
  │
  └─ NO → MainNavigationScreen (already logged in)
```

---

Time to test: ~5 minutes
Status: Ready to verify! ✅
