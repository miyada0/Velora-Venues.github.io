# Admin System Setup Guide

## 🚀 QUICK START

### Backend Setup
```bash
# 1. Navigate to backend
cd backend

# 2. Install dependencies (if not done)
npm install

# 3. Start MongoDB
mongod

# 4. Create admin user
node seedAdmin.js

# 5. Start server
node server.js
```

### Frontend - No Setup Needed
The Flutter app is already configured to handle admin authentication and routing.

---

## 🔐 Admin Credentials
```
Email: admin123@test.com
Password: mypassword
```

---

## 🎯 What Works

### Backend APIs (All Protected)
- ✅ POST `/api/auth/login` - Login with role detection
- ✅ POST `/api/auth/signup` - Signup with admin email detection
- ✅ GET `/api/admin/stats` - Dashboard statistics
- ✅ GET `/api/admin/pending-halls` - Pending hall approvals
- ✅ PUT `/api/admin/approve/:id` - Approve hall
- ✅ PUT `/api/admin/reject/:id` - Reject hall
- ✅ GET `/api/admin/halls` - All halls
- ✅ GET `/api/admin/users` - All users
- ✅ DELETE `/api/admin/user/:id` - Delete user
- ✅ GET `/api/admin/bookings` - All bookings

### Frontend Flow
1. User logs in with admin email
2. Backend returns role: "admin"
3. Auth VM detects role
4. Main.dart routes to AdminDashboardScreen
5. Admin dashboard shows statistics
6. Admin can navigate to:
   - Pending Halls (approve/reject)
   - All Halls (view)
   - Users (delete)
   - Bookings (view)

---

## 🧪 Testing Admin Features

### 1. Test Admin Login
```bash
POST http://localhost:5000/api/auth/login
{
  "email": "admin123@test.com",
  "password": "mypassword"
}
```
Response:
```json
{
  "token": "eyJ...",
  "user": {
    "_id": "...",
    "name": "Admin",
    "email": "admin123@test.com",
    "role": "admin",
    "isBlocked": false
  }
}
```

### 2. Test Admin Stats
```bash
GET http://localhost:5000/api/admin/stats
Header: Authorization: <token>
```

### 3. Test Pending Halls
```bash
GET http://localhost:5000/api/admin/pending-halls
Header: Authorization: <token>
```

---

## 📱 Frontend Testing

1. Build & run Flutter app
2. Tap "Login" on splash screen
3. Enter:
   - Email: `admin123@test.com`
   - Password: `mypassword`
4. Tap "Login"
5. You should be redirected to AdminDashboardScreen
6. Explore all admin features

---

## 🔧 Troubleshooting

### "Admin access required" Error
- Check that you're logged in with admin email
- Verify token is being sent in Authorization header
- Check backend console for middleware errors

### "Failed to fetch stats"
- Ensure MongoDB is running
- Ensure backend server is running on port 5000
- Check CORS settings in server.js

### Role Not Detected
- Check that login returns user object with role field
- Verify auth_vm.dart has userRole getter
- Check main.dart _getHome() function

---

## 📂 File Structure

```
backend/
├── routes/
│   ├── authRoutes.js (✅ Admin email detection)
│   └── adminRoutes.js (✅ All admin endpoints)
├── middleware/
│   ├── authMiddleware.js (✅ JWT verification)
│   └── adminMiddleware.js (✅ Role checking)
├── models/
│   ├── User.js (✅ Includes role field)
│   └── ...
└── seedAdmin.js (✅ Creates admin user)

wedding_hall_app/lib/
├── services/
│   └── admin_service.dart (✅ All admin API calls)
├── viewmodels/
│   └── auth_vm.dart (✅ Role getter added)
├── models/
│   ├── user_model.dart (✅ Role field)
│   ├── admin_stats_model.dart (✅ Stats model)
│   └── ...
├── views/admin/
│   ├── admin_dashboard_screen.dart (✅ Main dashboard)
│   ├── admin_pending_halls_screen.dart (✅ Approve/Reject)
│   ├── admin_users_screen.dart (✅ Delete users)
│   ├── admin_bookings_screen.dart (✅ View bookings)
│   └── admin_halls_screen.dart (✅ View halls)
└── main.dart (✅ Admin routing)
```

---

## ✅ Checklist Before Deploy

- [ ] MongoDB running
- [ ] Admin user created (`node seedAdmin.js`)
- [ ] Backend server running (`node server.js`)
- [ ] Flutter app connects to correct backend URL
- [ ] Can login with admin credentials
- [ ] Redirected to admin dashboard
- [ ] All admin API calls working
- [ ] Stats displaying correctly
- [ ] Pending halls showing
- [ ] Can approve/reject halls
- [ ] Can view and delete users
- [ ] Can view all bookings

---

## 🎓 Key Implementation Details

### Admin Email Detection
When user signs up or logs in with `admin123@test.com`, the backend automatically assigns `role: "admin"`

### Role-Based Navigation
In `main.dart`, the app checks `userRole` and routes:
- Admin role → AdminDashboardScreen
- Other roles → MainNavigationScreen

### Protected Routes
All admin API endpoints use two middleware:
1. `authMiddleware` - Verifies JWT token
2. `adminOnly` - Checks role === "admin"

### Safe Null Navigation
All nullable values handled with null coalescing (`??`) and null-safe access (`?.`)
