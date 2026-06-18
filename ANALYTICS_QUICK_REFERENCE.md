# 📊 Analytics Dashboard - Quick Reference

## 🚀 Quick Start Integration

### 1. Update Main Routes (main.dart)

Add these routes:
```dart
'/admin-analytics': (_) => AdminAnalyticsScreen(),
'/owner-analytics': (_) => OwnerAnalyticsScreen(),
```

### 2. Import Screens

```dart
import 'lib/screens/analytics/AdminAnalyticsScreen.dart';
import 'lib/screens/analytics/OwnerAnalyticsScreen.dart';
```

### 3. Add Navigation Button to Admin Dashboard

```dart
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/admin-analytics'),
  child: Text('📊 View Analytics'),
)
```

### 4. Add Navigation Button to Owner Dashboard

```dart
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/owner-analytics'),
  child: Text('📊 My Analytics'),
)
```

---

## 📁 Files Created

| File | Purpose |
|------|---------|
| `backend/routes/analyticsRoutes.js` | API endpoints for analytics |
| `lib/services/analyticsService.dart` | API calls |
| `lib/providers/analyticsProvider.dart` | State management |
| `lib/screens/analytics/AdminAnalyticsScreen.dart` | Admin dashboard UI |
| `lib/screens/analytics/OwnerAnalyticsScreen.dart` | Owner dashboard UI |

---

## 🔗 API Endpoints

### Admin Analytics
```
GET http://192.168.243.148:5000/api/analytics/admin
Headers: Authorization: Bearer {token}
```

**Response:**
- Bookings trend (30 days)
- Revenue trend (12 months)
- Top 5 halls
- Top 5 rated halls
- Summary stats

### Owner Analytics
```
GET http://192.168.243.148:5000/api/analytics/owner/{ownerId}
Headers: Authorization: Bearer {token}
```

**Response:** Same as admin but filtered to owner's halls only

---

## ✅ Checklist

- [x] Backend routes created
- [x] API endpoints working
- [x] Flutter service layer added
- [x] Riverpod provider created
- [x] Admin screen implemented
- [x] Owner screen implemented
- [x] Charts integrated (fl_chart)
- [x] Summary cards added
- [x] Lists with hall data added
- [x] Error handling implemented
- [x] Loading states added

**Next Steps:**
- [ ] Update main.dart with routes
- [ ] Add buttons to dashboards
- [ ] Test with real data
- [ ] Customize colors
- [ ] Deploy

---

## 🎨 Key Features

✅ **AdminAnalyticsScreen**
- System-wide metrics
- All halls analytics
- Global revenue tracking
- Overall performance

✅ **OwnerAnalyticsScreen**
- Owner's halls only
- Revenue per hall
- Hall ratings
- Performance comparison

✅ **Charts**
- Line chart: Booking trends
- Bar chart: Revenue trends
- Responsive design
- Interactive labels

✅ **Summary Cards**
- Total bookings
- Total revenue
- Total halls/users
- Average rating

---

## 🔧 Configuration

### Update Base URL (if needed)

In `lib/services/analyticsService.dart`:
```dart
static const String baseUrl = "http://192.168.243.148:5000/api/analytics";
```

### Update Owner ID (in OwnerAnalyticsScreen)

Currently uses placeholder 'ownerIdHere'. Update to get from auth provider:

```dart
final authProvider = ref.watch(authProvider);
final ownerId = authProvider.user?['_id'] ?? '';
ref.read(analyticsProvider.notifier).loadOwnerAnalytics(ownerId);
```

---

## 💡 Tips

1. **Data Freshness**: Consider caching data for 5 minutes
2. **Performance**: Dates are aggregated on backend (no N+1 queries)
3. **Security**: Each owner sees only their data
4. **Accessibility**: Font sizes, colors, and icons for easy reading

---

## 🧪 Manual Testing

1. **Admin Analytics:**
   - Navigate to `/admin-analytics`
   - Verify all metrics load
   - Check charts display data
   - Verify hall list is populated

2. **Owner Analytics:**
   - Navigate to `/owner-analytics`
   - Verify only owner's halls show
   - Check revenue calculation
   - Verify ratings display

3. **Error Handling:**
   - Disconnect internet
   - Verify error message shows
   - Check retry button works

---

## 📱 Screen Breakdown

### AdminAnalyticsScreen
```
┌─────────────────────┐
│  Admin Analytics    │
├─────────────────────┤
│ [Card] [Card]       │
│ [Card] [Card]       │
├─────────────────────┤
│ Bookings Trend      │
│ [Line Chart]        │
├─────────────────────┤
│ Revenue Trend       │
│ [Bar Chart]         │
├─────────────────────┤
│ Top Halls           │
│ [List Items]        │
├─────────────────────┤
│ Top Rated           │
│ [List Items]        │
└─────────────────────┘
```

### OwnerAnalyticsScreen
```
┌─────────────────────┐
│   My Analytics      │
├─────────────────────┤
│ [Card] [Card]       │
│ [Card] [Card]       │
├─────────────────────┤
│ Bookings Trend      │
│ [Line Chart]        │
├─────────────────────┤
│ Revenue Trend       │
│ [Bar Chart]         │
├─────────────────────┤
│ Hall Performance    │
│ [List Items]        │
├─────────────────────┤
│ Hall Ratings        │
│ [List Items]        │
└─────────────────────┘
```

---

## 🚨 Common Issues

| Issue | Solution |
|-------|----------|
| No data showing | Check MongoDB, ensure bookings exist |
| Charts not rendering | Verify `fl_chart` dependency in pubspec.yaml |
| API 401 error | Check token in SharedPreferences |
| State not updating | Verify `ConsumerWidget` is used |
| Owner sees all halls | Check `ownerId` filtering in backend |

---

**Status**: ✅ Ready for Integration
**Estimated Integration Time**: 10-15 minutes
