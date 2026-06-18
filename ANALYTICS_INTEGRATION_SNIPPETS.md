# 📊 Analytics - Integration Code Snippets

## 1️⃣ Update main.dart Routes

### Add to routes dictionary:

```dart
routes: {
  '/login': (_) => const LoginScreen(),
  '/home': (_) => const MainNavigationScreen(),
  '/admin-dashboard': (_) => const AdminDashboardScreen(),
  '/admin-analytics': (_) => AdminAnalyticsScreen(),      // ✨ NEW
  '/owner-analytics': (_) => OwnerAnalyticsScreen(),      // ✨ NEW
  '/add-hall': (_) => const AddHallScreen(),
  '/my-halls': (_) => const MyHallsScreen(),
  '/owner-dashboard': (_) => const OwnerDashboardScreen(),
  // ... rest of routes
}
```

### Add imports at top of main.dart:

```dart
import 'screens/analytics/AdminAnalyticsScreen.dart';
import 'screens/analytics/OwnerAnalyticsScreen.dart';
```

---

## 2️⃣ Admin Dashboard Integration

### Add this button to AdminDashboardScreen.dart

Find the dashboard button section and add:

```dart
// 📊 Analytics Button
Padding(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.pushNamed(context, '/admin-analytics');
    },
    icon: Icon(Icons.analytics, size: 22),
    label: Text('View Analytics'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF8B4789),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
),
```

### Or as a ListTile in a menu:

```dart
ListTile(
  leading: Icon(Icons.bar_chart, color: Color(0xFF8B4789)),
  title: Text('Analytics Dashboard'),
  subtitle: Text('View system-wide statistics'),
  trailing: Icon(Icons.arrow_forward),
  onTap: () {
    Navigator.pushNamed(context, '/admin-analytics');
  },
),
```

---

## 3️⃣ Owner Dashboard Integration

### Add this button to OwnerDashboardScreen.dart

Find the dashboard button section and add:

```dart
// 📊 Analytics Button
Padding(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.pushNamed(context, '/owner-analytics');
    },
    icon: Icon(Icons.analytics, size: 22),
    label: Text('My Analytics'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF8B4789),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
),
```

### Or as a GridItem:

```dart
GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, '/owner-analytics');
  },
  child: Container(
    decoration: BoxDecoration(
      color: Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFF8B4789), width: 1),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bar_chart,
          size: 40,
          color: Color(0xFF8B4789),
        ),
        SizedBox(height: 10),
        Text(
          'My Analytics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4789),
          ),
        ),
      ],
    ),
  ),
),
```

---

## 4️⃣ Full Admin Dashboard Example

```dart
import 'package:flutter/material.dart';
import 'package:wedding_hall_booking_app/screens/analytics/AdminAnalyticsScreen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Color(0xFF8B4789),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            
            // Dashboard Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                // Existing buttons...
                
                // 📊 Analytics Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin-analytics');
                  },
                  icon: Icon(Icons.analytics),
                  label: Text('View Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B4789),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 30),
            
            // Other dashboard widgets...
          ],
        ),
      ),
    );
  }
}
```

---

## 5️⃣ Full Owner Dashboard Example

```dart
import 'package:flutter/material.dart';
import 'package:wedding_hall_booking_app/screens/analytics/OwnerAnalyticsScreen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Dashboard'),
        backgroundColor: Color(0xFF8B4789),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            
            // Dashboard Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(15),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                // Existing grid items...
                
                // 📊 Analytics Card
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/owner-analytics');
                  },
                  child: _buildDashboardCard(
                    icon: Icons.bar_chart,
                    title: 'My Analytics',
                    backgroundColor: Color(0xFFFFF3E0),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF8B4789), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Color(0xFF8B4789)),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4789),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6️⃣ Navigation MenuIntegration

### If using a side menu/drawer:

```dart
ListTile(
  leading: Icon(Icons.dashboard, color: Color(0xFF8B4789)),
  title: Text('Dashboard'),
  onTap: () {
    Navigator.pushNamed(context, '/admin-dashboard');
  },
),
Divider(),
ListTile(
  leading: Icon(Icons.analytics, color: Color(0xFF8B4789)),
  title: Text('Analytics'),
  trailing: Badge(label: Text('New')),
  onTap: () {
    Navigator.pushNamed(context, '/admin-analytics');
  },
),
ListTile(
  leading: Icon(Icons.settings),
  title: Text('Settings'),
  onTap: () {
    // Navigate to settings
  },
),
```

---

## 7️⃣ Bottom Navigation Integration

### If using bottom tab navigation:

```dart
class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    AdminAnalyticsScreen(),      // ✨ NEW
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',              // ✨ NEW
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
```

---

## 8️⃣ Action Menu Integration

### Quick action menu in toolbar:

```dart
AppBar(
  title: Text('Admin Dashboard'),
  actions: [
    PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.analytics),
              SizedBox(width: 10),
              Text('View Analytics'),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/admin-analytics');
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 10),
              Text('Settings'),
            ],
          ),
          onTap: () {
            // Navigate to settings
          },
        ),
      ],
    ),
  ],
)
```

---

## ✅ Testing After Integration

```dart
// Test Navigation
test('Navigate to admin analytics', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.tap(find.byIcon(Icons.analytics));
  await tester.pumpAndSettle();
  
  expect(find.text('📊 Admin Analytics'), findsOneWidget);
});
```

---

## 🎨 Color Customization

Replace `Color(0xFF8B4789)` with your brand color throughout:

```dart
// Primary Purple (Current)
Color(0xFF8B4789)

// Or use from your theme:
Theme.of(context).primaryColor
```

---

## 📋 Checklist

- [ ] Copy integration code snippets
- [ ] Update main.dart with routes
- [ ] Update admin dashboard
- [ ] Update owner dashboard
- [ ] Test navigation
- [ ] Verify data loads
- [ ] Check styling matches theme
- [ ] Test error states
- [ ] Deploy

---

**Ready to integrate!** Copy the code snippets above into your respective files.
