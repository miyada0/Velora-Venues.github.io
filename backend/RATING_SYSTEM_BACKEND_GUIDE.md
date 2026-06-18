# Backend Implementation: Google Maps & Rating System

## 🔌 Express.js Endpoints to Implement

Add these endpoints to your `backend/routes/ratingRoutes.js`

---

## 1️⃣ SUBMIT RATING

```javascript
router.post('/:hallId', isAuthenticated, async (req, res) => {
  try {
    const { hallId } = req.params;
    const { rating } = req.body;
    const userId = req.user._id; // From auth middleware

    // Validate rating
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        message: "Rating must be between 1 and 5",
      });
    }

    // Check if user already rated this hall
    let existingRating = await Rating.findOne({
      userId: userId,
      hallId: hallId,
    });

    if (existingRating) {
      // Update existing rating
      existingRating.rating = rating;
      existingRating.updatedAt = new Date();
      await existingRating.save();
    } else {
      // Create new rating
      const newRating = new Rating({
        userId: userId,
        hallId: hallId,
        rating: rating,
        createdAt: new Date(),
      });
      await newRating.save();
    }

    // Calculate new average rating for this hall
    const ratings = await Rating.find({ hallId: hallId });
    const averageRating = 
      ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length;

    // Update hall's average rating
    await Hall.findByIdAndUpdate(hallId, { rating: averageRating });

    res.status(200).json({
      message: "Rating submitted successfully",
      averageRating: averageRating.toFixed(1),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

---

## 2️⃣ GET HALL RATING DATA (Optional)

```javascript
router.get('/:hallId', async (req, res) => {
  try {
    const { hallId } = req.params;

    // Get all ratings for this hall
    const ratings = await Rating.find({ hallId: hallId });

    if (ratings.length === 0) {
      return res.status(200).json({
        hallId: hallId,
        averageRating: 0,
        totalRatings: 0,
      });
    }

    // Calculate average
    const averageRating =
      ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length;

    // Distribution by star
    const distribution = {
      5: ratings.filter(r => r.rating === 5).length,
      4: ratings.filter(r => r.rating === 4).length,
      3: ratings.filter(r => r.rating === 3).length,
      2: ratings.filter(r => r.rating === 2).length,
      1: ratings.filter(r => r.rating === 1).length,
    };

    res.status(200).json({
      hallId: hallId,
      averageRating: parseFloat(averageRating.toFixed(1)),
      totalRatings: ratings.length,
      distribution: distribution,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

---

## 3️⃣ GET USER'S RATING FOR HALL (Optional)

```javascript
router.get('/:hallId/my-rating', isAuthenticated, async (req, res) => {
  try {
    const { hallId } = req.params;
    const userId = req.user._id;

    const userRating = await Rating.findOne({
      userId: userId,
      hallId: hallId,
    });

    if (!userRating) {
      return res.status(404).json({
        message: "No rating found for this user",
      });
    }

    res.status(200).json({
      rating: userRating.rating,
      submittedAt: userRating.createdAt,
      updatedAt: userRating.updatedAt,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

---

## 📦 Rating Model Schema

Create `backend/models/Rating.js`:

```javascript
const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  hallId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hall',
    required: true,
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5,
  },
  comment: {
    type: String,
    default: '',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Compound index to prevent duplicate ratings per user per hall
ratingSchema.index({ userId: 1, hallId: 1 }, { unique: true });

module.exports = mongoose.model('Rating', ratingSchema);
```

---

## 🔗 Register Routes in server.js

```javascript
const ratingRoutes = require('./routes/ratingRoutes');

// ... other routes ...

app.use('/api/ratings', ratingRoutes);
```

---

## 🛡️ Protected Endpoints

Both endpoints should require authentication:

```javascript
// Middleware check
const isAuthenticated = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ message: "Unauthorized" });
  }
  next();
};
```

---

## 📌 Database Changes Needed

1. **Create Rating Collection** in MongoDB
2. **Update Hall Model** to include `rating` field (if not exists)
3. **Add Unique Compound Index** on Rating collection

```javascript
// In MongoDB admin:
db.ratings.createIndex({ userId: 1, hallId: 1 }, { unique: true })
```

---

## ✅ Testing with Postman

### 1. Submit Rating
```
POST http://localhost:5000/api/ratings/HALL_ID
Headers: 
  - Authorization: Bearer YOUR_TOKEN
  - Content-Type: application/json
Body: {
  "rating": 4.5
}
```

### 2. Get Hall Ratings
```
GET http://localhost:5000/api/ratings/HALL_ID
```

### 3. Get My Rating
```
GET http://localhost:5000/api/ratings/HALL_ID/my-rating
Headers:
  - Authorization: Bearer YOUR_TOKEN
```

---

## 🚀 Complete Integration Steps

1. **Create Rating Model** (`models/Rating.js`)
2. **Create Routes File** (`routes/ratingRoutes.js`)
3. **Register Routes** in `server.js`
4. **Test Endpoints** with Postman
5. **Verify Database** stores ratings correctly
6. **Test with Flutter App**

---

## 📊 Database Queries (MongoDB)

### Get all ratings for a hall:
```javascript
db.ratings.find({ hallId: ObjectId("HALL_ID") })
```

### Get specific user's rating for hall:
```javascript
db.ratings.findOne({ 
  userId: ObjectId("USER_ID"), 
  hallId: ObjectId("HALL_ID") 
})
```

### Get average rating:
```javascript
db.ratings.aggregate([
  { $match: { hallId: ObjectId("HALL_ID") } },
  { $group: { _id: null, avgRating: { $avg: "$rating" } } }
])
```

### Get rating distribution:
```javascript
db.ratings.aggregate([
  { $match: { hallId: ObjectId("HALL_ID") } },
  { 
    $group: { 
      _id: "$rating", 
      count: { $sum: 1 } 
    } 
  },
  { $sort: { _id: -1 } }
])
```

---

## 🔐 Error Handling

**400 Bad Request** - Invalid rating value:
```json
{ "message": "Rating must be between 1 and 5" }
```

**401 Unauthorized** - No auth token:
```json
{ "message": "Unauthorized" }
```

**404 Not Found** - No rating exists (for get):
```json
{ "message": "No rating found for this user" }
```

**500 Server Error** - Database error:
```json
{ "message": "Internal server error" }
```

---

## 📝 Sample Response After Submit

```json
{
  "message": "Rating submitted successfully",
  "averageRating": "4.3"
}
```

---

## 💡 Performance Tips

1. **Index queries**: Already done with compound index
2. **Cache averages**: Consider caching hall average ratings
3. **Batch updates**: Update hall average only after rating saved
4. **Limit queries**: Add pagination if getting all ratings
5. **Rate limit**: Add rate limiting (1 rating per hour per user per IP)

---

## 🎯 Next Steps

1. Implement the 3 endpoints above
2. Test with Postman before connecting Flutter
3. Handle errors gracefully
4. Deploy and test with Flutter app
5. Monitor database for performance

All 3 endpoints are independent - you can implement them one at a time!
