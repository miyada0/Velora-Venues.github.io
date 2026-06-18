# 🔐 DEBUG TOKEN FLOW - Communication Between Frontend & Backend

## 📡 COMPLETE REQUEST/RESPONSE CYCLE

### STEP 1: LOGIN REQUEST
```
📤 Flutter → Backend

POST http://10.99.227.20:5000/api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Console Output:
🔄 AUTH SERVICE: Sending login request...
```

---

### STEP 2: BACKEND VERIFICATION
```
Backend Processing:

✅ User found in database
✅ Password matches (bcrypt verification)
✅ Generate JWT token:

jwt.sign(
  { id: "user_mongo_id", role: "user" },
  "wedding_hall_super_secret_key_2024",
  { expiresIn: "7d" }
)

Console Output:
📋 LOGIN RESPONSE:
   Email: user@example.com
   Role: user
   Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

### STEP 3: LOGIN RESPONSE
```
📥 Backend → Flutter

HTTP 200 OK
Content-Type: application/json

{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY0ZWU...",
  "user": {
    "_id": "64ee...",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "user"
  }
}

Console Output:
📦 AUTH SERVICE: Response received:
  ✅ Status: 200
  Token: eyJhbGciOiJIUzI1NiIsInR5c...
  User: { _id, email, name, role }
  Role: user
```

---

### STEP 4: TOKEN STORAGE (Flutter)
```
🔑 Saving to SharedPreferences

await prefs.setString('auth_token', token);

Console Output:
🔐 Setting authorization token...
✅ Token saved and set successfully

[Wait 200ms for storage to persist]
```

---

### STEP 5: AUTHENTICATED API REQUEST
```
📤 Flutter → Backend

Now when making ANY request:

GET http://10.99.227.20:5000/api/halls
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5c...
Content-Type: application/json

Console Output:
➡️ GET /halls
🔐 Token added (eyJhbGciOiJIUzI1NiIsIn...)
```

---

### STEP 6: BACKEND TOKEN VERIFICATION
```
Backend Processing:

🔐 AUTH MIDDLEWARE DEBUG:
  📋 Auth Header: Bearer eyJhbGciOiJIUzI1NiIsInR5c...
  🔑 Token: eyJhbGciOiJIUzI1NiIsInR5c...
  
  jwt.verify(
    "eyJhbGciOiJIUzI1NiIsInR5c...",
    "wedding_hall_super_secret_key_2024"  // MUST MATCH!
  )
  
  ✅ Token verified successfully
  👤 Decoded userId: 64ee...
  👥 User role: user
  
  req.userId = "64ee..."
  req.userRole = "user"
  next() → Proceed to route handler
```

---

### STEP 7: SUCCESSFUL RESPONSE
```
📥 Backend → Flutter

HTTP 200 OK
Content-Type: application/json

[Response data with null-safety applied]
{
  "halls": [
    {
      "_id": "...",
      "name": "...",
      "price": 50000,        // ✅ NOT NULL - default 0
      "capacity": 500,       // ✅ NOT NULL - default 0
      "rating": 4.5,         // ✅ NOT NULL - default 0
      "images": ["..."],     // ✅ NOT NULL - default []
      "facilities": [...]    // ✅ NOT NULL - default []
    }
  ]
}

Console Output:
✅ 200 /halls
[Data parsed successfully]
```

---

## 🚨 ERROR SCENARIOS

### SCENARIO 1: EXPIRED TOKEN (7 days later)
```
📤 Flutter → Backend

GET /halls
Authorization: Bearer [expired_token]

🔐 AUTH MIDDLEWARE:
  jwt.verify() throws TokenExpiredError
  
  ❌ Token verification failed: jwt expired
  🔍 Error type: TokenExpiredError

📥 Response:
HTTP 401 UNAUTHORIZED
{
  "message": "Invalid token",
  "error": "TOKEN_EXPIRED"
}

🔥 Dio Interceptor handles:
  🚨 401 UNAUTHORIZED on /halls
  🔐 Triggering logout callback due to 401
  
  // NOT login/signup, so trigger logout
  _handleUnauthorized()
  
🔓 AuthVM: Automatic logout triggered by 401
✅ AuthVM: Auto-logout successful
```

---

### SCENARIO 2: TOKEN SENT WITH LOGIN REQUEST (Don't logout!)
```
📤 Flutter → Backend (during re-login)

POST /auth/login
Authorization: Bearer [old_expired_token]  // Still in headers
{
  "email": "...",
  "password": "..."
}

🔥 Dio Interceptor detects 401 but:
  
  NOT login/signup, so DON'T logout
  
  if (!e.requestOptions.path.contains("/auth/login"))
    return;  // EXIT - don't trigger logout!

✅ Request continues normally
✅ New valid token received
✅ Old token replaced
```

---

### SCENARIO 3: MISSING TOKEN (Not logged in)
```
📤 Flutter → Backend

GET /halls
Authorization: [MISSING - no token in storage]

🔥 Dio Interceptor onRequest:
  
  final token = await storage.read(key: "token");
  
  if (token == null) {
    ⚠️ No token in storage for request /halls
    // Request proceeds without Authorization header
  }

🔐 AUTH MIDDLEWARE:
  
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    ❌ ERROR: No authorization header provided
    return 401 "No token provided"
  }

📥 Error Response:
HTTP 401 UNAUTHORIZED
{ "message": "No token provided", "error": "MISSING_TOKEN" }
```

---

### SCENARIO 4: MALFORMED TOKEN
```
📤 Flutter → Backend

GET /halls
Authorization: Bearer [not_a_valid_jwt]

🔐 AUTH MIDDLEWARE:
  
  jwt.verify("[not_a_valid_jwt]", SECRET)
  
  ❌ Token verification failed: invalid token
  🔍 Error type: JsonWebTokenError

📥 Response:
HTTP 401 UNAUTHORIZED
{ "message": "Invalid token", "error": "MALFORMED_TOKEN" }
```

---

### SCENARIO 5: DIFFERENT SECRET (The Bug!)
```
[This scenario is now FIXED ✅]

Before Fix - Different Secrets:
- authMiddleware uses: "secret"
- rbacMiddleware uses: "secret_key"

🚨 Token signed with "secret" but verified with "secret_key"

jwt.verify(
  token,
  "secret_key"  // ❌ WRONG - different from signing secret!
)

ERROR: Invalid signature
401 UNAUTHORIZED

❌ User gets logged out immediately
❌ All API calls fail with 401
❌ Endless logout/login cycle

---

After Fix - Unified Secret:
Both use: "wedding_hall_super_secret_key_2024"

✅ Token signed and verified with SAME secret
✅ Auth succeeds
✅ All API calls work
```

---

## 📊 TOKEN STRUCTURE

The JWT token has 3 parts separated by dots:

```
Header.Payload.Signature

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJpZCI6IjY0ZWU2NTdjNWY3MzQxMDA0NGZhYTEwNyIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNjkwNTEwNDAwLCJleHAiOjE2OTExMTUyMDB9.
dXHbkJePtYp8-L4H7k9pM3XqL2rJ6vN8qOzS5tUwXyZ
```

### Part 1: Header (Base64 Decoded)
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### Part 2: Payload (Base64 Decoded)
```json
{
  "id": "64ee657c5f734100445aa107",
  "role": "user",
  "iat": 1690510400,
  "exp": 1691115200
}
```

### Part 3: Signature
```
HMACSHA256(
  Base64(header) + '.' + Base64(payload),
  "wedding_hall_super_secret_key_2024"
)
```

---

## ✅ CONSOLE LOGS YOU SHOULD SEE

### Login Success:
```
🔄 AUTH SERVICE: Sending login request...
📦 AUTH SERVICE: Response received:
  ✅ Status: 200
  Token: eyJhbGciOiJIUzI1NiIsInR5c...
  User: { _id: '64ee...', email: '...', role: 'user' }
  Role: user
  ✅ Token saved to storage and headers

📋 AUTH VM LOGIN DEBUG:
  ✅ Login successful
  📧 Email: user@example.com
  👤 Role: user
  🔐 Token: eyJhbGciOiJIUzI1NiIsInR5c...
  ✅ Auth state updated
```

### API Request Success:
```
➡️ GET /halls
🔐 Token added (eyJhbGciOiJIUzI1NiIsIn...)
✅ 200 /halls
```

### Token Verified on Backend:
```
🔐 AUTH MIDDLEWARE DEBUG:
  📋 Auth Header: Bearer eyJhbGciOiJIUzI1NiIsInR5c...
  🔑 Token: eyJhbGciOiJIUzI1NiIsInR5c...
  ✅ Token verified successfully
  👤 Decoded userId: 64ee657c5f734100445aa107
  👥 User role: user
```

---

## 🎯 VERIFY YOUR FIX IS WORKING

1. ✅ See "Token saved" message
2. ✅ See "Token added" in next request
3. ✅ See "Token verified successfully" in backend
4. ✅ API returns 200, not 401
5. ✅ No "Session expired" false alerts
6. ✅ Can make multiple requests without logout
7. ✅ Wishlist, bookings, admin all work
8. ✅ No "Null is not a subtype" errors

If you see all 8 ✅ → **AUTH SYSTEM IS FIXED!**
