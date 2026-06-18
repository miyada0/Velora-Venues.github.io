# Google Maps & Rating System Integration Guide

## ✅ What's Been Added

### 1️⃣ **Google Maps Redirection** 
When users tap the location, it opens Google Maps with the hall's location.

### 2️⃣ **User Rating System**
Users can rate halls (1-5 stars) and see the average rating.

---

## 📦 NEW FILES CREATED

### Services:
- `lib/services/rating_service.dart` - Handles all rating API calls

### Widgets:
- `lib/widgets/location_widget.dart` - Clickable location with Google Maps integration
- `lib/widgets/hall_rating_widget.dart` - Star rating UI with submission

### Updated Files:
- `lib/views/hall/hall_details_screen.dart` - Integrated both features
- `pubspec.yaml` - Added 3 new packages

---

## 🎯 FEATURE #1: GOOGLE MAPS REDIRECTION

### UI Behavior:
- Location text is now **blue and underlined** (indicating it's clickable)
- Tap to open Google Maps with the hall location
- Shows loading spinner while opening maps
- Shows error message if maps unavailable

### How It Works:
```dart
LocationWidget(
  locationText: hall.location,
)
```

### Dependencies Added:
```yaml
url_launcher: ^6.2.0
geolocator: ^9.0.2
```

### Code Location:
[location_widget.dart](lib/widgets/location_widget.dart)

---

## ⭐ FEATURE #2: USER RATING SYSTEM

### UI Components:
- **Rating Badge** at top right showing average rating (existing)
- **New Rating Section** with:
  - Current average rating display
  - Interactive 5-star rating bar
  - Submit button with loading state
  - Helper text showing user's current rating

### Placement:
Located between **Amenities** and **Calendar** sections for natural flow

### Dependencies Added:
```yaml
flutter_rating_bar: ^4.0.1
```

### Code Location:
[hall_rating_widget.dart](lib/widgets/hall_rating_widget.dart)

---

## 🔌 BACKEND API REQUIREMENTS

### 1. Rating Submission Endpoint
```
POST /api/ratings/:hallId
```

**Request Body:**
```json
{
  "rating": 4.5
}
```

**Response (Success):**
```json
{
  "message": "Rating submitted successfully",
  "averageRating": 4.3
}
```

**Response (Error):**
```json
{
  "message": "Unauthorized",
  "statusCode": 401
}
```

---

### 2. Fetch Rating Data Endpoint (Optional)
```
GET /api/ratings/:hallId
```

**Response:**
```json
{
  "hallId": "abc123",
  "averageRating": 4.3,
  "totalRatings": 42,
  "distributionBy": {
    "5": 30,
    "4": 8,
    "3": 4
  }
}
```

---

### 3. Get User's Existing Rating (Optional)
```
GET /api/ratings/:hallId/my-rating
```

**Response (User has rated):**
```json
{
  "rating": 4.0,
  "submittedAt": "2024-01-15T10:30:00Z"
}
```

**Response (User hasn't rated - 404):**
```json
{
  "message": "No rating found"
}
```

---

## 📱 HOW TO USE

### For Developers:

1. **Install Dependencies:**
```bash
cd wedding_hall_app
flutter pub get
```

2. **Android Permissions** (Already should be there, but check):
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

3. **Backend Integration:**
Implement the 3 API endpoints above in your Express backend

### For QA/Testing:

**Test Google Maps:**
- Tap on location text (blue underlined text below hall name)
- Should open Google Maps with the hall location
- Works offline if maps app is installed

**Test Rating:**
- Scroll to "Rate This Hall" section
- Tap stars to select rating (shows feedback)
- Tap "Submit Rating" button
- Should show success message if backend is ready
- Rating badge at top should update

---

## 💡 IMPLEMENTATION CHECKLIST

### Frontend (✅ Already Done):
- [x] add `url_launcher` and `flutter_rating_bar` packages
- [x] Create `LocationWidget` with Google Maps integration
- [x] Create `HallRatingWidget` with star UI
- [x] Create `RatingService` for API calls
- [x] Integrate both widgets in `HallDetailsScreen`
- [x] Handle loading and error states
- [x] Maintain existing booking/payment flow

### Backend (⚠️ You Need to Do):
- [ ] Create `POST /api/ratings/:hallId` endpoint
- [ ] Store rating in database
- [ ] Calculate average rating
- [ ] Implement `GET /api/ratings/:hallId` (optional)
- [ ] Implement `GET /api/ratings/:hallId/my-rating` (optional)
- [ ] Add proper error handling (401, 400, 404)
- [ ] Add rate limiting to prevent spam

---

## 🗺️ GOOGLE MAPS FEATURE DETAILS

### How Location Opening Works:

1. **User taps location** → `_openGoogleMaps()` is called
2. **Check native maps** → Tries to use device's Google Maps app
3. **Fallback to web** → If app not installed, opens in browser
4. **Error handling** → Shows snackbar if unable to open

### Example Locations (tested):
- "Perinthalmanna, Malappuram" ✅
- "Erode, Tamil Nadu" ✅
- "Kochi, Kerala" ✅
- Any location string works!

### Browser Fallback URL Format:
```
https://www.google.com/maps/search/{ENCODED_LOCATION}
```

---

## ⭐ RATING FEATURE DETAILS

### Rating Flow:

1. **Load user's existing rating** → Shown on component mount
2. **User taps stars** → Visual feedback (amber color)
3. **User taps Submit** → API call with animation
4. **Success** → Show snackbar + update UI
5. **Error** → Show error message, allow retry

### UI States:

**Before Rating:**
```
Rate This Hall          [Avg: 4.2 ⭐]
        ☆ ☆ ☆ ☆ ☆
    [Submit Rating]
```

**After Rating:**
```
Rate This Hall          [Avg: 4.2 ⭐]
        ★ ★ ★ ★ ☆
    You rated 4.0 ⭐
    [Update Rating]
```

**Loading:**
```
[Loading spinner in button]
```

---

## 🔐 SECURITY NOTES

### Authentication:
- Both features require valid auth token (handled by `ApiService`)
- Token automatically sent in all requests via interceptor
- 401 errors trigger logout via `SafeApi.handle401()`

### Rate Limiting (Backend):
- Recommend: 1 rating per user per hall per day
- Or: Allow update but count as modification, not new rating

---

## 🐛 TROUBLESHOOTING

### Google Maps Not Opening:
**Issue:** Tapping location does nothing
**Solution:**
- Ensure device has internet
- Check if Google Maps app is installed (or browser)
- On emulator, might need web fallback
- Check logcat for URL encoding issues

### Rating Not Submitting:
**Issue:** Submit button shows error
**Solution:**
- Verify backend endpoint is working (test with Postman)
- Check API URL matches: `/api/ratings/:hallId`
- Ensure user is authenticated (check token)
- Check backend logs for errors

### Rating Shows Old Value:
**Issue:** Rating doesn't update after submission
**Solution:**
- The widget uses local state, not API pull after submit
- Backend should return new average in response
- Optional: Implement refresh to re-fetch from backend

---

## 🚀 FUTURE ENHANCEMENTS

### Could Add:
1. **Written Reviews** - Text feedback along with rating
2. **Review Photos** - Users can upload pictures
3. **Helpful Votes** - "Was this review helpful?" feature
4. **Moderation** - Admin approval for reviews
5. **Review Sorting** - Recent, helpful, highest/lowest rated
6. **Hall Photos** - Users can upload venue photos in reviews
7. **Distance Display** - Show km from user's location
8. **Directions** - Copy address, get directions button

---

## 📞 SUPPORT

### Files to Reference:
- [location_widget.dart](lib/widgets/location_widget.dart) - Location logic
- [hall_rating_widget.dart](lib/widgets/hall_rating_widget.dart) - Rating logic
- [rating_service.dart](lib/services/rating_service.dart) - API integration
- [hall_details_screen.dart](lib/views/hall/hall_details_screen.dart) - Integration point

### Common Issues:
- Ensure `pubspec.yaml` was updated with new packages
- Run `flutter pub get` to install packages
- Check that imports are correct (no typos)
- Verify backend endpoints match exactly

---

## ✨ DESIGN CONSISTENCY

Both new features maintain your existing design system:
- Colors: Brand pink (`AppTheme.primary`)
- Spacing: Using `AppTheme.paddingMedium`, etc.
- Typography: Matches existing text styles
- Shadows: Consistent soft shadows (8px blur)
- Rounded corners: Using `AppTheme.borderRadiusMedium`

No existing functionality was broken - all features are **purely additive**.

---

**Status:** ✅ Ready to use with backend implementation
