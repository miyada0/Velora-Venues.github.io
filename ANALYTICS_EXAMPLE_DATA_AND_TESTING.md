# 📊 Analytics Dashboard - Example Data & Testing

## Example API Responses

### Admin Analytics Response

```json
{
  "success": true,
  "data": {
    "bookingsTrend": [
      { "_id": "2024-01-15", "count": 3, "revenue": 30000 },
      { "_id": "2024-01-16", "count": 5, "revenue": 50000 },
      { "_id": "2024-01-17", "count": 4, "revenue": 40000 },
      { "_id": "2024-01-18", "count": 7, "revenue": 70000 },
      { "_id": "2024-01-19", "count": 6, "revenue": 60000 },
      { "_id": "2024-01-20", "count": 8, "revenue": 80000 },
      { "_id": "2024-01-21", "count": 5, "revenue": 50000 },
      { "_id": "2024-01-22", "count": 9, "revenue": 90000 },
      { "_id": "2024-01-23", "count": 6, "revenue": 60000 },
      { "_id": "2024-01-24", "count": 7, "revenue": 70000 },
      { "_id": "2024-01-25", "count": 10, "revenue": 100000 },
      { "_id": "2024-01-26", "count": 8, "revenue": 80000 },
      { "_id": "2024-01-27", "count": 5, "revenue": 50000 },
      { "_id": "2024-01-28", "count": 6, "revenue": 60000 },
      { "_id": "2024-01-29", "count": 9, "revenue": 90000 },
      { "_id": "2024-01-30", "count": 7, "revenue": 70000 }
    ],
    "revenueTrend": [
      { "_id": "2023-01", "totalRevenue": 450000, "bookingCount": 45 },
      { "_id": "2023-02", "totalRevenue": 520000, "bookingCount": 52 },
      { "_id": "2023-03", "totalRevenue": 610000, "bookingCount": 61 },
      { "_id": "2023-04", "totalRevenue": 580000, "bookingCount": 58 },
      { "_id": "2023-05", "totalRevenue": 720000, "bookingCount": 72 },
      { "_id": "2023-06", "totalRevenue": 850000, "bookingCount": 85 },
      { "_id": "2023-07", "totalRevenue": 920000, "bookingCount": 92 },
      { "_id": "2023-08", "totalRevenue": 880000, "bookingCount": 88 },
      { "_id": "2023-09", "totalRevenue": 750000, "bookingCount": 75 },
      { "_id": "2023-10", "totalRevenue": 650000, "bookingCount": 65 },
      { "_id": "2023-11", "totalRevenue": 780000, "bookingCount": 78 },
      { "_id": "2023-12", "totalRevenue": 1100000, "bookingCount": 110 }
    ],
    "topHalls": [
      {
        "hallId": "507f1f77bcf86cd799439011",
        "hallName": "Grand Palace Wedding Hall",
        "bookingCount": 125,
        "totalRevenue": 3125000
      },
      {
        "hallId": "507f1f77bcf86cd799439012",
        "hallName": "Royal Banquet Complex",
        "bookingCount": 98,
        "totalRevenue": 2450000
      },
      {
        "hallId": "507f1f77bcf86cd799439013",
        "hallName": "Crystal Garden Estate",
        "bookingCount": 87,
        "totalRevenue": 2090000
      },
      {
        "hallId": "507f1f77bcf86cd799439014",
        "hallName": "Sunrise Convention Hall",
        "bookingCount": 76,
        "totalRevenue": 1900000
      },
      {
        "hallId": "507f1f77bcf86cd799439015",
        "hallName": "Heritage Pavilion",
        "bookingCount": 65,
        "totalRevenue": 1625000
      }
    ],
    "ratings": [
      {
        "hallId": "507f1f77bcf86cd799439011",
        "hallName": "Grand Palace Wedding Hall",
        "averageRating": 4.8,
        "reviewCount": 125
      },
      {
        "hallId": "507f1f77bcf86cd799439012",
        "hallName": "Royal Banquet Complex",
        "averageRating": 4.6,
        "reviewCount": 98
      },
      {
        "hallId": "507f1f77bcf86cd799439016",
        "hallName": "Emerald Dreams Venue",
        "averageRating": 4.7,
        "reviewCount": 89
      },
      {
        "hallId": "507f1f77bcf86cd799439013",
        "hallName": "Crystal Garden Estate",
        "averageRating": 4.5,
        "reviewCount": 87
      },
      {
        "hallId": "507f1f77bcf86cd799439014",
        "hallName": "Sunrise Convention Hall",
        "averageRating": 4.4,
        "reviewCount": 76
      }
    ],
    "summary": {
      "totalBookings": 1250,
      "totalRevenue": 31250000,
      "totalHalls": 48,
      "totalUsers": 2340
    }
  }
}
```

---

## What Each Section Displays

### 📦 Summary Cards

| Card | Value | Color |
|------|-------|-------|
| Total Bookings | 1250 | Green |
| Total Revenue | ₹3,12,50,000 | Orange |
| Total Halls | 48 | Blue |
| Total Users | 2340 | Purple |

### 📈 Bookings Trend (Line Chart)

Shows daily bookings for the last 30 days:
- **X-axis**: Days (Day 1-30)
- **Y-axis**: Number of bookings (0-10)
- **Line**: Purple trending line
- **Points**: Dots at each day's value

**Pattern**: Slight upward trend with peaks on weekends

### 💰 Revenue Trend (Bar Chart)

Shows monthly revenue for the last 12 months:
- **X-axis**: Months (M1-M12)
- **Y-axis**: Revenue in ₹
- **Bars**: Purple bars for each month
- **Highest**: December (₹11,00,000)
- **Lowest**: January (₹4,50,000)

**Pattern**: Seasonal - peaks in wedding season (June-December)

### 🏆 Top Halls

Ranked by number of bookings:

1. **Grand Palace Wedding Hall**
   - Bookings: 125
   - Revenue: ₹31,25,000
   - Rank badge: 1️⃣

2. **Royal Banquet Complex**
   - Bookings: 98
   - Revenue: ₹24,50,000
   - Rank badge: 2️⃣

3. **Crystal Garden Estate**
   - Bookings: 87
   - Revenue: ₹20,90,000
   - Rank badge: 3️⃣

4. **Sunrise Convention Hall**
   - Bookings: 76
   - Revenue: ₹19,00,000
   - Rank badge: 4️⃣

5. **Heritage Pavilion**
   - Bookings: 65
   - Revenue: ₹16,25,000
   - Rank badge: 5️⃣

### ⭐ Top Rated Halls

Ranked by average rating:

1. **Grand Palace Wedding Hall**
   - Rating: ⭐⭐⭐⭐⭐ 4.8/5
   - Reviews: 125

2. **Emerald Dreams Venue**
   - Rating: ⭐⭐⭐⭐☆ 4.7/5
   - Reviews: 89

3. **Royal Banquet Complex**
   - Rating: ⭐⭐⭐⭐☆ 4.6/5
   - Reviews: 98

4. **Crystal Garden Estate**
   - Rating: ⭐⭐⭐⭐☆ 4.5/5
   - Reviews: 87

5. **Sunrise Convention Hall**
   - Rating: ⭐⭐⭐⭐☆ 4.4/5
   - Reviews: 76

---

## Owner Analytics Response Example

```json
{
  "success": true,
  "data": {
    "bookingsTrend": [
      { "_id": "2024-01-15", "count": 1, "revenue": 10000 },
      { "_id": "2024-01-16", "count": 2, "revenue": 20000 },
      { "_id": "2024-01-17", "count": 1, "revenue": 10000 },
      { "_id": "2024-01-18", "count": 3, "revenue": 30000 },
      { "_id": "2024-01-19", "count": 2, "revenue": 20000 },
      { "_id": "2024-01-20", "count": 2, "revenue": 20000 },
      { "_id": "2024-01-21", "count": 1, "revenue": 10000 },
      { "_id": "2024-01-22", "count": 3, "revenue": 30000 },
      { "_id": "2024-01-23", "count": 2, "revenue": 20000 },
      { "_id": "2024-01-24", "count": 2, "revenue": 20000 },
      { "_id": "2024-01-25", "count": 3, "revenue": 30000 },
      { "_id": "2024-01-26", "count": 2, "revenue": 20000 },
      { "_id": "2024-01-27", "count": 1, "revenue": 10000 },
      { "_id": "2024-01-28", "count": 2, "revenue": 20000 },
      { "_id": "2024-01-29", "count": 3, "revenue": 30000 },
      { "_id": "2024-01-30", "count": 2, "revenue": 20000 }
    ],
    "revenueTrend": [
      { "_id": "2023-01", "totalRevenue": 150000, "bookingCount": 15 },
      { "_id": "2023-02", "totalRevenue": 160000, "bookingCount": 16 },
      { "_id": "2023-03", "totalRevenue": 180000, "bookingCount": 18 },
      { "_id": "2023-04", "totalRevenue": 170000, "bookingCount": 17 },
      { "_id": "2023-05", "totalRevenue": 200000, "bookingCount": 20 },
      { "_id": "2023-06", "totalRevenue": 250000, "bookingCount": 25 },
      { "_id": "2023-07", "totalRevenue": 280000, "bookingCount": 28 },
      { "_id": "2023-08", "totalRevenue": 260000, "bookingCount": 26 },
      { "_id": "2023-09", "totalRevenue": 220000, "bookingCount": 22 },
      { "_id": "2023-10", "totalRevenue": 200000, "bookingCount": 20 },
      { "_id": "2023-11", "totalRevenue": 240000, "bookingCount": 24 },
      { "_id": "2023-12", "totalRevenue": 350000, "bookingCount": 35 }
    ],
    "topHalls": [
      {
        "hallId": "507f1f77bcf86cd799439011",
        "hallName": "My Grand Hall",
        "bookingCount": 42,
        "totalRevenue": 1050000
      },
      {
        "hallId": "507f1f77bcf86cd799439017",
        "hallName": "My Royal Venue",
        "bookingCount": 28,
        "totalRevenue": 700000
      }
    ],
    "ratings": [
      {
        "hallId": "507f1f77bcf86cd799439011",
        "hallName": "My Grand Hall",
        "averageRating": 4.7,
        "reviewCount": 42
      },
      {
        "hallId": "507f1f77bcf86cd799439017",
        "hallName": "My Royal Venue",
        "averageRating": 4.5,
        "reviewCount": 28
      }
    ],
    "summary": {
      "totalBookings": 70,
      "totalRevenue": 1750000,
      "totalHalls": 2
    }
  }
}
```

---

## Owner Dashboard Example

### 📦 Summary Cards for Owner

| Card | Value | Color |
|------|-------|-------|
| Total Bookings | 70 | Green |
| Total Revenue | ₹17,50,000 | Orange |
| Total Halls | 2 | Blue |
| Avg Rating | 4.6 ⭐ | Yellow |

### Hall Performance (Your Halls)

1. **My Grand Hall**
   - 📅 Bookings: 42
   - 💰 Revenue: ₹10,50,000

2. **My Royal Venue**
   - 📅 Bookings: 28
   - 💰 Revenue: ₹7,00,000

### Hall Ratings (Your Halls)

1. **My Grand Hall**
   - ⭐ Rating: 4.7/5
   - Reviews: 42

2. **My Royal Venue**
   - ⭐ Rating: 4.5/5
   - Reviews: 28

---

## 🧪 Testing Scenarios

### Scenario 1: Fresh Data Load
1. Navigate to `/admin-analytics`
2. Page shows loading indicator
3. Data loads after 2-3 seconds
4. All charts and lists populate

**Expected**: All 5 sections filled with data

### Scenario 2: Different Owner
1. Log in as different owner
2. Navigate to `/owner-analytics`
3. See only their halls' data

**Expected**: Different numbers for each owner

### Scenario 3: Error Handling
1. Disconnect internet
2. Refresh page
3. See error message with retry button

**Expected**: Error displayed, retry works

### Scenario 4: Empty Data
1. New hall with no bookings
2. View analytics
3. See "No data available" messages

**Expected**: Graceful handling of empty states

---

## 🎨 Visual Layout

### Admin Analytics Screen Layout

```
┌─────────────────────────────────┐
│      📊 Admin Analytics         │
├─────────────────────────────────┤
│  [📅 1250]  [💰 ₹3.1Cr]        │
│  [🏠 48]    [👥 2340]           │
├─────────────────────────────────┤
│    📈 Bookings Trend (30 days)  │
│  ╱╲  ╱╲╱╲  ╱╲  ╱╲              │
│ ╱  ╲╱    ╲╱  ╲╱                 │
├─────────────────────────────────┤
│   💰 Revenue Trend (12 months)  │
│  ▀▁ ▂  ▃ ▂  ▃ ▄  ▅  ▆  ▇  ▆    │
│ ▎ ▏ ▎▏▏ ▎▏▏ ▏  ▏  ▏  ▏  ▏     │
├─────────────────────────────────┤
│          🏆 Top Halls           │
│  1. Grand Palace      125 ⭐     │
│  2. Royal Banquet     98 ⭐      │
│  3. Crystal Garden    87 ⭐      │
│  4. Sunrise Hall      76 ⭐      │
│  5. Heritage Hall     65 ⭐      │
├─────────────────────────────────┤
│       ⭐ Top Rated Halls        │
│  1. Grand Palace      4.8/5      │
│  2. Emerald Dreams    4.7/5      │
│  3. Royal Banquet     4.6/5      │
│  4. Crystal Garden    4.5/5      │
│  5. Sunrise Hall      4.4/5      │
└─────────────────────────────────┘
```

### Owner Analytics Screen Layout

```
┌─────────────────────────────────┐
│       📊 My Analytics           │
├─────────────────────────────────┤
│  [📅 70]   [💰 ₹17.5L]         │
│  [🏠 2]    [⭐ 4.6]             │
├─────────────────────────────────┤
│    📈 Bookings Trend (30 days)  │
│     ╱╲  ╱╲╱╲  ╱╲  ╱╲           │
│    ╱  ╲╱    ╲╱  ╲╱             │
├─────────────────────────────────┤
│   💰 Revenue Trend (12 months)  │
│   ▎  ▏  ▏▏  ▎▏ ▏  ▏  ▏  ▎▏    │
├─────────────────────────────────┤
│    🏆 Your Halls Performance    │
│  • My Grand Hall        42      │
│    Revenue: ₹10,50,000          │
│  • My Royal Venue       28      │
│    Revenue: ₹7,00,000           │
├─────────────────────────────────┤
│         ⭐ Hall Ratings         │
│  • My Grand Hall      4.7/5     │
│    42 reviews                   │
│  • My Royal Venue     4.5/5     │
│    28 reviews                   │
└─────────────────────────────────┘
```

---

## 📊 Chart Data Examples

### Bookings Trend Line Chart
```
Points:
(0, 3), (1, 5), (2, 4), (3, 7), (4, 6), (5, 8), (6, 5), 
(7, 9), (8, 6), (9, 7), (10, 10), (11, 8), (12, 5), 
(13, 6), (14, 9), (15, 7)

Pattern: Zigzag with upward trend
Color: Purple (#8B4789)
Curve: Smooth interpolation
```

### Revenue Trend Bar Chart
```
Bars:
Jan: 450k, Feb: 520k, Mar: 610k, Apr: 580k, 
May: 720k, Jun: 850k, Jul: 920k, Aug: 880k, 
Sep: 750k, Oct: 650k, Nov: 780k, Dec: 1100k

Pattern: Seasonal increase (Jun-Dec higher)
Color: Purple (#8B4789)
Tallest: December (1100k)
```

---

## 🔢 Number Formatting

### Indian Format (₹)
- 1000 → ₹1,000
- 100000 → ₹1,00,000
- 1000000 → ₹10,00,000
- 3125000 → ₹31,25,000

### Rating Format
- 4.8/5 (one decimal place)
- Always includes /5

### Count Format
- 125 bookings
- 98 halls
- 2340 users

---

## 🧩 Data Relationships

```
Hall A
├── 42 Bookings
├── ₹10,50,000 Revenue
├── 4.7/5 Rating
└── 42 Reviews

Hall B
├── 28 Bookings
├── ₹7,00,000 Revenue
├── 4.5/5 Rating
└── 28 Reviews

System Total
├── 1250 Bookings
├── ₹31,25,00,000 Revenue
├── 48 Halls
└── 2340 Users
```

---

## ✅ Data Validation

- Bookings count ≥ 0
- Revenue always ≥ 0
- Ratings between 0-5
- Review counts match overall pattern
- Dates in ascending order
- No duplicate dates

---

**Ready to test!** Use this data as reference when testing the analytics dashboard.
