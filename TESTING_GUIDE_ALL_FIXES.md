# TESTING GUIDE - Verify All 12 Fixes

## Pre-Testing Setup

1. **Backend Running:** 
   ```bash
   cd backend
   npm install  # if needed
   npm start
   ```

2. **Flutter App:** Build and run on emulator/device

3. **Example Data:** Ensure you have:
   - Multiple test bookings
   - Test halls with images
   - Admin and owner accounts

---

## ✅ TEST 1: Cancel Booking - 24 Hour Check

**Test Case 1A: Future Booking (>24 hours)**
1. Create booking for 2-3 days in future
2. Go to "My Bookings"
3. **Expected:** See red "Cancel Booking" button
4. **Tap:** Button should work
5. **Check:** Booking marked as cancelled with grey status

**Test Case 1B: Near Booking (<24 hours)**
1. Create booking for tomorrow or today
2. Go to "My Bookings"  
3. **Expected:** See yellow message "Cannot cancel within 24 hours"
4. **Check:** Button is NOT clickable
5. **Message:** Should say "Cannot cancel within 24 hours" ✅

**Verification Code:**
```dart
// Check this is working in my_bookings_screen.dart, line ~278
final hoursUntilBooking = bookingDateLocal.difference(now).inHours;
final canCancel = hoursUntilBooking > 24;
```

---

## ✅ TEST 2: Images Loading - All Screens

**Test Case 2A: My Bookings Screen**
1. Open "My Bookings"
2. Wait 2-3 seconds for images to load
3. **Expected:** Hall images appear with cover photo
4. **Check:** No broken image icon
5. **Verify:** Image URL is full path: `http://10.99.227.20:5000/uploads/...`

**Test Case 2B: Admin Pending Halls**
1. Login as admin
2. Go to "Pending Halls"
3. **Expected:** Each pending hall shows thumbnail image
4. **Loading:** Show spinner while loading
5. **Error:** If no image, show placeholder icon

**Test Case 2C: Owner My Halls**
1. Login as owner
2. Go to "My Halls"
3. **Expected:** Hall cards show images with status badge
4. **Status Colors:**
   - Green = Approved ✅
   - Orange = Pending ⏳
   - Red = Rejected ❌

**Test Case 2D: Hall Statistics**
1. Click on any hall from "My Halls"
2. Goes to "Hall Statistics" screen
3. **Expected:** Large hall image at top loads with spinner
4. **Check:** After loading, image displays clearly

**Verification Code:**
```dart
// Check ImageUtils is being used:
ImageUtils.getImageUrl(hall.images.first)
// Should construct: http://10.99.227.20:5000/uploads/path
```

---

## ✅ TEST 3: API Retry Logic

**Test Case 3A: Network Unstable**
1. Enable airplane mode briefly, then turn off
2. Make any API call (load bookings, stats, etc.)
3. **Expected:** 
   - First attempt fails (shows loading)
   - Auto-retries up to 3 times
   - Eventually succeeds OR shows error
4. **Check:** No immediate "Connection Failed" without retries

**Test Case 3B: Slow Network**
1. Set network throttling (Developer Tools)
2. Load data that takes >5 seconds
3. **Expected:** Should eventually succeed, not timeout
4. **Timeouts:** 10 seconds per request

**Verification Code:**
```dart
// In api_service.dart:
connectTimeout: const Duration(seconds: 10),
receiveTimeout: const Duration(seconds: 10),
// + RetryInterceptor with exponential backoff
```

---

## ✅ TEST 4: Admin Approval Status Update

**Test Case 4A: Status Change Flow**
1. **As Owner:** Register new hall (status = "pending")
2. **As Admin:** 
   - Go to "Pending Halls"
   - See the new hall
   - Tap "Approve"
   - See snackbar "Hall Approved ✅"
3. **As Owner:**
   - Go back to "My Halls"
   - **Pull down** to refresh
   - **Expected:** Hall now shows GREEN "APPROVED" badge
4. **Verify:** Without refresh, status might be cached (old behavior)

**Test Case 4B: Automatic After Approval**
1. Owner goes to "My Halls" WHILE admin approves
2. After approval, owner pulls to refresh
3. **Expected:** Status updates to APPROVED immediately
4. **Key:** Pull-to-refresh calls `ref.invalidate(ownerHallsProvider)`

**Verification Code:**
```dart
// In owner_dashboard_screen.dart:
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(ownerHallsProvider);
  },
  // ...
)
```

---

## ✅ TEST 5: Theme - Pink + White

**Visual Inspection:**
1. Open any screen
2. **AppBar:** Should be pink (#E91E63) with white text
3. **Buttons:** All primary buttons should be pink
4. **Background:** White (not beige/gold)
5. **Cards:** White cards with subtle shadow
6. **Status Badges:**
   - Green for APPROVED
   - Orange for PENDING
   - Red for REJECTED

**Screens to Check:**
- [ ] Home/Hall List
- [ ] Booking Form
- [ ] My Bookings
- [ ] Admin Dashboard
- [ ] Pending Halls
- [ ] Admin Bookings
- [ ] Owner Dashboard
- [ ] Hall Statistics

**Verification Code:**
```dart
// In app_theme.dart:
static const Color primary = Color(0xFFE91E63);  // Pink
static const Color backgroundColor = Colors.white;  // White
// No more gold/beige colors
```

---

## ✅ TEST 6: Loading Indicators & Empty States

**Test Case 6A: Empty States**
1. Admin: Go to "Pending Halls" when none exist
   - **Expected:** "No pending halls" message + icon
2. Owner: New account with no halls
   - **Expected:** "No halls registered yet" + "Register Hall" button
3. Bookings: User with no bookings
   - **Expected:** "No bookings found" + icon

**Test Case 6B: Loading Indicators**
1. Open "My Bookings" (data loads)
   - **Expected:** See spinner while loading
   - Once loaded, spinner disappears
2. Open image-heavy screen (Pending Halls)
   - **Expected:** Each image shows spinner during load
   - Spinner replaced by image once loaded
3. Error case:
   - Close network briefly
   - Load data
   - **Expected:** Error message + "Retry" button
   - Tap "Retry" → Load again

**Test Case 6C: Pull-to-Refresh**
1. Go to "My Halls" (Owner)
2. **Pull down** from top
   - **Expected:** Refresh spinner appears
   - Data reloads
   - Spinner disappears
3. Go to "Pending Halls" (Admin)
   - Same behavior

**Verification Code:**
```dart
// Pull-to-refresh:
RefreshIndicator(
  onRefresh: _refreshFunction,  // Async function
  child: FutureBuilder(...)
)

// Loading indicator:
CircularProgressIndicator(strokeWidth: 2)

// Empty state:
if (items.isEmpty) {
  return Center(child: Column(...))
}
```

---

## ✅ TEST 7: Type Safety - No Crashes

**Test Cases:**
1. Open any hall details → No crashes
2. Make booking → No type errors
3. Admin approve/reject → Works properly
4. Check booking details → All data shows correctly

**What to Watch For:**
- ❌ "type '_Map<dynamic,dynamic>' is not a subtype of 'String'"
- ❌ "null is not of type type 'String'"
- ❌ "Object is not of type 'List<String>'"

**If any appear:**
- Check models are using `fromJson` factory properly
- Check no raw map access like `data['field']`
- Verify all type conversions in factories

---

## ✅ TEST 8: Backend Endpoints

**Test Using Postman or curl:**

**1. POST /bookings**
```bash
curl -X POST http://10.99.227.20:5000/api/bookings \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "hallId": "HALL_ID",
    "date": "2026-04-15",
    "fullName": "John Doe",
    "phone": "9876543210",
    "email": "john@example.com",
    "totalAmount": 50000
  }'
```
**Expected:** 200 OK with bookingId

**2. GET /admin/bookings**
```bash
curl -X GET http://10.99.227.20:5000/api/admin/bookings \
  -H "Authorization: Bearer ADMIN_TOKEN"
```
**Expected:** 200 OK with array of bookings with populated hall and user

**3. PUT /admin/approve/:id**
```bash
curl -X PUT http://10.99.227.20:5000/api/admin/approve/HALL_ID \
  -H "Authorization: Bearer ADMIN_TOKEN"
```
**Expected:** 200 OK with hall status="approved"

**4. GET /halls/owner/halls**
```bash
curl -X GET http://10.99.227.20:5000/api/halls/owner/halls \
  -H "Authorization: Bearer OWNER_TOKEN"
```
**Expected:** 200 OK with array of owner's halls (all statuses)

---

## ✅ QUICK TEST CHECKLIST

### For Each Test:
- [ ] Feature works as described
- [ ] No unexpected errors in console
- [ ] UI is responsive (not frozen)
- [ ] Colors are correct (pink+white)
- [ ] Text is readable and properly aligned
- [ ] Images load without errors
- [ ] Navigation back works
- [ ] Data persists correctly
- [ ] No type errors or crashes

### Critical Path:
1. [ ] User can see bookings with images
2. [ ] User can cancel (if >24 hrs)
3. [ ] Admin can see pending halls with images
4. [ ] Admin can approve halls
5. [ ] Owner sees updated status after refresh
6. [ ] All images load properly
7. [ ] Pull-to-refresh works
8. [ ] Theme is pink+white
9. [ ] No crashes or type errors
10. [ ] Loading spinners appear appropriately

---

## 🐛 TROUBLESHOOTING

**Issue: Images still not loading**
- Check backend is running
- Verify `/uploads` folder exists with images
- Check backend has: `app.use('/uploads', express.static('uploads'))`
- Verify image paths in database don't have extra slashes

**Issue: Cancel button still showing when <24 hours**
- Check `DateTime.now().toLocal()` is being used
- Verify time zones match between server and client
- Check browser console for exact hours value

**Issue: Pull-to-refresh not working**
- Verify RefreshIndicator wraps the FutureBuilder
- Check `ref.invalidate(provider)` is called
- Make sure provider is being watched with `ref.watch()`

**Issue: Theme still gold/beige**
- Clear Flutter build: `flutter clean`
- Rebuild app: `flutter run`
- Check app_theme.dart has primary = pink
- Restart app completely

---

**All tests passing? Ready for production! 🚀**

Generated: March 22, 2026
