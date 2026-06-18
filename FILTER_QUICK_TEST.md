# ⚡ QUICK FILTER TESTING GUIDE

**Status**: ✅ Ready to Test  
**Time to Test**: ~10-15 minutes  

---

## 🚀 QUICK START

### Run the App
```bash
cd wedding_hall_app
flutter run
```

---

## 📋 TEST SCENARIOS

### **TEST 1: Capacity Range Filter**

**Step 1:** Tap Filter Button (⚙️)  
**Step 2:** Look for "Capacity Range" slider  
**Step 3:** Set Min: 500, Max: 1500  
**Step 4:** Tap "Apply Filters"  
**Expected Result:** Only halls with 500-1500 capacity shown  

✅ **Proof:** Check hall capacity values in the results

---

### **TEST 2: Rating Range Filter**

**Step 1:** Tap Filter Button (⚙️)  
**Step 2:** Look for "Rating Range" slider  
**Step 3:** Set Min: 3.5, Max: 5.0  
**Step 4:** Tap "Apply Filters"  
**Expected Result:** Only halls with 3.5-5.0 rating shown  

✅ **Proof:** Check rating badges on hall cards

---

### **TEST 3: Sort by Rating**

**Step 1:** Apply any filters  
**Step 2:** Look at "Sort By" dropdown  
**Step 3:** Select "Rating: High to Low"  
**Step 4:** Tap "Apply Filters"  
**Expected Result:** Halls sorted by rating (highest first)  

✅ **Proof:** Compare rating values top to bottom

---

### **TEST 4: Sort by Capacity**

**Step 1:** Apply any filters  
**Step 2:** Look at "Sort By" dropdown  
**Step 3:** Select "Capacity: High to Low"  
**Step 4:** Tap "Apply Filters"  
**Expected Result:** Halls sorted by capacity (largest first)  

✅ **Proof:** Compare capacity values top to bottom

---

### **TEST 5: Combined Filters**

**Step 1:** Tap Filter Button (⚙️)  
**Step 2:** Set:
- Capacity: 800-1500
- Rating: 4.0-5.0
- Location: Malappuram
- Sort: Rating High to Low

**Step 3:** Tap "Apply Filters"  
**Expected Result:** Only high-rated, large halls in Malappuram, sorted by rating  

✅ **Proof:** All three filters should be visible in results

---

## 🎯 MANUAL VERIFICATION

Open DevTools (Flutter Inspector) or check API calls:

### **Check Flutter Side**
```
1. Open Filter Sheet
2. Look at sliders:
   ✅ Capacity: RangeSlider (not single slider)
   ✅ Rating: RangeSlider (not single slider)
3. Look at Sort dropdown:
   ✅ "Price: Low to High"
   ✅ "Price: High to Low"
   ✅ "Rating: High to Low" (NEW)
   ✅ "Capacity: High to Low" (NEW)
```

### **Check Backend (Optional)**

Run this in Postman or curl:

```bash
# Test capacity filter
curl "http://localhost:5000/api/halls?minCapacity=500&maxCapacity=1500"

# Test rating filter
curl "http://localhost:5000/api/halls?minRating=3.5&maxRating=5.0"

# Test sorting
curl "http://localhost:5000/api/halls?sortBy=rating_high"

# Test all together
curl "http://localhost:5000/api/halls?minCapacity=500&maxCapacity=1500&minRating=3.5&maxRating=5.0&sortBy=rating_high"
```

---

## ✅ CHECKLIST

### **UI Elements**
- [ ] Capacity Range slider visible
- [ ] Rating Range slider visible
- [ ] Both show min and max values
- [ ] Sort dropdown shows 4 options
- [ ] New sort options ("Rating", "Capacity") added

### **Functionality**
- [ ] Capacity filter works (shows correct results)
- [ ] Rating filter works (shows correct results)
- [ ] Sort by rating works (sorted correctly)
- [ ] Sort by capacity works (sorted correctly)
- [ ] Combining filters works

### **API**
- [ ] Query parameters sent correctly
- [ ] Backend receives parameters
- [ ] Database query filters correctly
- [ ] Results sorted correctly
- [ ] No errors in console/backend logs

### **Edge Cases**
- [ ] Set capacity: 0-500 (small halls)
- [ ] Set capacity: 1500-2000 (large halls)
- [ ] Set rating: 1.0-3.0 (lower-rated)
- [ ] Set rating: 4.5-5.0 (high-rated)
- [ ] Multiple locations selected
- [ ] Price + Capacity + Rating combined

---

## 🐛 TROUBLESHOOTING

### **Issue: Sliders not showing**
✅ Make sure you're running latest code  
✅ Try: `flutter clean && flutter pub get && flutter run`

### **Issue: Filters not applying**
✅ Check Flutter console for errors  
✅ Check backend logs (Node.js terminal)  
✅ Verify network request in DevTools

### **Issue: Results not changing**
✅ Verify database has halls with different capacities/ratings  
✅ Check if halls match the filter criteria  
✅ Try extreme values first (e.g., capacity 0-100 for testing)

### **Issue: Sort not working**
✅ Check if "sortBy" parameter sent to API  
✅ Verify backend sort logic  
✅ Try refreshing the app

---

## 📊 EXPECTED API CALLS

### **Before (Old)**
```
GET /halls?minCapacity=500&minRating=3.5&price_low,price_high
```

### **After (New)**
```
GET /halls?minCapacity=500&maxCapacity=1500&minRating=3.5&maxRating=5.0&sortBy=rating_high
```

✅ Notice the new parameters: `maxCapacity`, `maxRating`, `sortBy`

---

## ⏱️ TEST TIME ESTIMATE

| Test | Time |
|------|------|
| Capacity filter | 1-2 min |
| Rating filter | 1-2 min |
| Sort by rating | 1 min |
| Sort by capacity | 1 min |
| Combined filters | 2-3 min |
| Edge cases | 2-3 min |
| **Total** | **10-15 min** |

---

## 🎉 SUCCESS CRITERIA

```
✅ All 4 filter types working
✅ RangeSliders displaying correctly
✅ Sort options applied correctly
✅ Combined filters working
✅ Results accurate and complete
✅ No UI breaks or errors
✅ Performance smooth (no lag)
✅ Ready for production
```

---

**When All Tests Pass** → App is ready for deployment! 🚀
