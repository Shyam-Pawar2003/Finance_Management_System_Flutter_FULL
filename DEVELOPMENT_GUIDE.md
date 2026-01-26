# Development Guide - Finance Management System

## Overview

This document provides comprehensive technical documentation for developers working with the Finance Management System Flutter application.

## Architecture

### Application Structure

```
Finance Management System
│
├── Authentication Layer
│   ├── Role Selection (User, CompanyAdmin, Employee)
│   ├── Login Validation
│   └── Credential Management
│
├── User Layer (Regular Users)
│   ├── Home Dashboard
│   ├── Financial Analytics
│   └── Profile Management
│
├── Authority Layer (Company Management)
│   ├── Company Dashboard
│   ├── Project Management
│   ├── Finance Tracking
│   ├── Employee Management
│   └── Task Assignment
│
└── Employee Layer
    ├── Task Management
    ├── Schedule Tracking
    ├── Payment Information
    └── Profile Management
```

## Technology Stack

### Frontend
- **Framework:** Flutter 3.0+
- **Language:** Dart 2.17+
- **UI Library:** Material Design 3
- **State Management:** StatefulWidget (local state)

### Current Storage
- Local variables (temporary)
- Ready for SQLite/Firebase integration

### Future Technologies
- Firebase Firestore (cloud database)
- Firebase Authentication
- REST API integration
- Push Notifications (Firebase Cloud Messaging)

## File Organization

### Core Files

#### `lib/main.dart`
**Purpose:** Application entry point and routing configuration

**Key Components:**
```dart
- MaterialApp setup
- Named routes definition
- Theme configuration
- Home screen assignment
```

**Routes Defined:**
```
/login → LoginScreen
/register → RegistrationScreen
/home → HomeScreen
/dashboard → DashboardScreen
/profile → UserProfileScreen
/company → CompanyManagementScreen
/employee-tasks → EmployeeTaskScreen
/task-assignment → TaskAssignmentScreen
```

#### `lib/screens/login_screen.dart`
**Purpose:** User authentication with role selection

**Key Features:**
- Role dropdown (User, CompanyAdmin, Employee)
- Email validation (@ symbol check)
- Password validation (minimum 6 characters)
- Password visibility toggle
- Form validation
- Conditional navigation based on role

**State Variables:**
```dart
String _selectedRole        // User role selection
bool _isPasswordHidden      // Password visibility
TextEditingController emailController
TextEditingController passwordController
```

**Key Methods:**
```dart
void _login()               // Validates and navigates
@override void dispose()    // Cleans up controllers
```

#### `lib/screens/registration_screen.dart`
**Purpose:** New user account creation

**Key Features:**
- Name validation (3+ characters)
- Email validation (@ symbol)
- Password validation (6+ characters)
- Password confirmation matching
- Visibility toggles
- Proper resource disposal

**Validation Rules:**
```dart
Name:       Minimum 3 characters
Email:      Must contain @
Password:   Minimum 6 characters
Confirm:    Must match password field
```

#### `lib/screens/home_screen.dart`
**Purpose:** Main user dashboard with 4-tab navigation

**Tabs:**
1. **Dashboard** - Financial overview
2. **Add Transaction** - Transaction creation (placeholder)
3. **Transactions** - Transaction history
4. **Profile** - Settings and preferences

**Key Data Displayed:**
- Balance card
- Income/Expense summary
- Recent transactions
- Profile information

#### `lib/screens/dashboard_screen.dart`
**Purpose:** Detailed financial analytics for regular users

**Features:**
- Spending analysis by category
- Budget tracking with progress bars
- Category breakdown (Groceries 36%, Entertainment 26%, etc.)
- Quarterly performance metrics

**Data Structure:**
```dart
categories: [
  {name: 'Groceries', percent: 36},
  {name: 'Entertainment', percent: 26},
  {name: 'Utilities', percent: 22},
  {name: 'Transport', percent: 16},
]
```

#### `lib/screens/user_profile_screen.dart`
**Purpose:** User profile management with editable fields

**Editable Fields:**
- Name
- Email
- Phone
- Location

**Additional Sections:**
- Account statistics
- Settings options
- Logout functionality

#### `lib/screens/company_management_screen.dart`
**Purpose:** Complete company operations dashboard

**4 Main Tabs:**

1. **Dashboard Tab**
   - Company overview card (name, founded year, employees)
   - KPI metric cards
   - Recent activity timeline

2. **Projects Tab**
   - Ongoing projects (8 total)
   - Completed projects (24 total)
   - Project progress tracking
   - Link to task assignment

3. **Finance Tab**
   - Revenue/Expense/Profit overview
   - Active loans tracking (2 loans)
   - Quarterly performance (Q1-Q4)
   - Interest rate calculations

4. **Employees Tab**
   - Employee statistics
   - Overtime tracking (12 employees)
   - Leave tracking (8 on leave)
   - Full employee roster with:
     - Position, Department, Salary, Join Date

**Key Data:**
```dart
Company Info:
- Name: TechCorp Industries
- Founded: 2015
- Employees: 150

Financial Data:
- Revenue: $2.5M
- Expenses: $1.75M
- Profit: $750K
- Loans: $500K

Loans:
- National Bank: $300K at 6.5%
- State Bank: $200K at 5.8%

Projects:
- Ongoing: 8 (45%-80% progress)
- Completed: 24 (with budgets)

Employees:
- Total: 150
- On Overtime: 12
- On Leave: 8
- New this month: 5
```

#### `lib/screens/task_assignment_screen.dart`
**Purpose:** Task management and assignment system

**Features:**
- Create new task assignments
- Select employee from dropdown
- Choose project assignment
- Set priority (Low, Medium, High, Urgent)
- Pick due date with date picker
- View all assigned tasks
- Task summary cards
- Color-coded priorities
- Status tracking

**Task Creation Dialog:**
```dart
Fields:
- Task Name (required)
- Description (optional)
- Assign to Employee (dropdown)
- Project (dropdown)
- Priority (dropdown)
- Due Date (date picker)
```

**Task Display:**
```dart
Information Shown:
- Task name and priority
- Assigned employee
- Project name
- Status (Pending/In Progress)
- Due date
```

#### `lib/screens/employee_task_screen.dart`
**Purpose:** Employee dashboard with 4-tab system

**Tabs:**

1. **Tasks Tab**
   - Task summary cards
   - Today's tasks with progress
   - Upcoming tasks list
   - Priority indicators

2. **Schedule Tab**
   - Today's status (check-in, hours, status)
   - Weekly schedule
   - Work hours tracking
   - Leave requests

3. **Payment Tab**
   - Monthly salary display
   - Earnings breakdown:
     - Base Salary
     - Overtime Pay
     - Bonuses
     - Deductions
   - Net total
   - Payment history

4. **Profile Tab**
   - Employee information
   - Department, Join Date
   - Quick statistics
   - Account options

**Key Data:**
```dart
Employee:
- Name: John Doe
- Position: Senior Developer
- Salary: $5,000/month
- Overtime Rate: $37.50/hour

Sample Tasks:
- 15 total tasks
- 8 completed
- 7 pending

Sample Schedule:
- Check-in: 9:00 AM
- Hours worked: 6.5 hours
- Overtime: 28 hours/month
```

## State Management

### Current Approach
**Local State with StatefulWidget**

Each screen manages its own state:
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // State variables
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    // UI rendering
  }
}
```

### Data Flow
1. User interacts with UI
2. setState() updates local state
3. Widget rebuilds with new state
4. UI reflects changes

### Future Improvements
Consider implementing:
- Provider for state management
- GetX for simpler syntax
- BLoC pattern for complex logic
- Riverpod for reactive programming

## Form Validation

### Email Validation
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  if (!value.contains('@')) {
    return 'Please enter a valid email';
  }
  return null;
}
```

### Password Validation
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
```

### Custom Validators
You can extend validation:
```dart
bool _isStrongPassword(String password) {
  return password.contains(RegExp(r'[A-Z]')) &&
         password.contains(RegExp(r'[a-z]')) &&
         password.contains(RegExp(r'[0-9]'));
}
```

## Navigation System

### Named Routes
```dart
// Define in main.dart
routes: {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  // ...
}

// Navigate
Navigator.of(context).pushNamed('/home');

// Navigate and remove previous routes
Navigator.of(context).pushNamedAndRemoveUntil(
  '/login',
  (route) => false,
);
```

### Navigation Flow
```
Login → Select Role
  ↓
Regular User → Home (4 tabs) → Logout
Company Authority → Company (4 tabs) + Task Assignment → Logout
Employee → Tasks (4 tabs) → Logout
```

## UI Components

### Custom Widgets

#### Summary Card
```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(/*content*/),
  ),
)
```

#### Task Card
```dart
Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Title and priority
        // Progress bar
        // Status and due date
      ],
    ),
  ),
)
```

#### Progress Bar
```dart
LinearProgressIndicator(
  value: 0.65,
  minHeight: 6,
  backgroundColor: Colors.grey.shade300,
  valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
)
```

## Color System

### Primary Colors
```dart
Colors.green          // User interface
Colors.blueAccent     // Company authority
Colors.teal           // Employee interface
```

### Status Colors
```dart
Colors.red            // High priority / Urgent
Colors.orange         // Medium priority / Overtime
Colors.green          // Low priority / Completed
Colors.blue           // Normal / Info
```

## Memory Management

### TextEditingController Disposal
```dart
@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

This prevents memory leaks and ensures proper cleanup.

## Common Patterns

### Building Lists
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(child: /*item*/);
  },
)
```

### Conditional Widget Rendering
```dart
if (isLoading) {
  return CircularProgressIndicator();
} else {
  return ListView(/*content*/);
}
```

### Dialog Creation
```dart
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text('Title'),
      content: Text('Content'),
      actions: [
        TextButton(onPressed: /*action*/, child: Text('Cancel')),
      ],
    );
  },
)
```

## Testing Scenarios

### Regular User Flow
1. Login as "User" with any email@example.com
2. Navigate through home dashboard tabs
3. View financial analytics
4. Access profile settings
5. Logout

### Company Authority Flow
1. Login as "CompanyAdmin"
2. View company dashboard with KPIs
3. Check ongoing projects
4. Review financial overview
5. View employee information
6. Assign tasks to employees
7. Logout

### Employee Flow
1. Login as "Employee"
2. View assigned tasks
3. Check work schedule
4. Review payment information
5. Access profile
6. Logout

## Debugging Tips

### Print Debugging
```dart
print('Debug: $variable');
print('State changed: $_selectedIndex');
```

### Flutter DevTools
```bash
flutter pub global activate devtools
devtools
flutter run --observatory-port=9999
```

### Common Issues

**Memory Leak:**
- Ensure TextEditingControllers are disposed
- Check for infinite loops in build

**Navigation Issues:**
- Verify routes are defined in main.dart
- Check for duplicate route names
- Ensure imports are correct

**UI Not Updating:**
- Call setState() for state changes
- Check if widget is mounted
- Verify rebuild conditions

## Performance Optimization

### Best Practices
1. Use `const` for stateless widgets
2. Split large widgets into smaller ones
3. Use `ListView.builder` for large lists
4. Avoid unnecessary rebuilds
5. Profile with Flutter DevTools

### Memory Efficiency
- Dispose controllers and streams
- Avoid building complex widgets in build()
- Use ImageCache for images
- Clear caches when needed

## Code Style Guidelines

### Naming Conventions
```dart
// Classes: PascalCase
class LoginScreen { }

// Variables: camelCase
String userEmail = '';

// Constants: camelCase with const
const double defaultPadding = 16.0;

// Private members: _camelCase
String _privateVariable = '';
```

### File Organization
```dart
// 1. Imports
// 2. Class definition
// 3. State class
// 4. Build method
// 5. Helper methods
// 6. Private methods
```

## Future Enhancement Roadmap

### Phase 1: Data Persistence
- [ ] SQLite integration
- [ ] Local data caching
- [ ] Offline support

### Phase 2: Backend Integration
- [ ] API authentication
- [ ] Real-time synchronization
- [ ] Cloud backup

### Phase 3: Advanced Features
- [ ] Machine learning analytics
- [ ] Video conferencing
- [ ] Document management
- [ ] Biometric auth

### Phase 4: Mobile Optimization
- [ ] Push notifications
- [ ] Location services
- [ ] Camera integration
- [ ] Offline-first sync

## Resources

### Flutter Documentation
- https://flutter.dev/docs
- https://dart.dev/guides

### Material Design
- https://material.io/design
- https://m3.material.io/

### Common Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  # Add these for future enhancements:
  # provider: ^6.0.0
  # firebase_core: ^2.0.0
  # cloud_firestore: ^4.0.0
```

## Support & Troubleshooting

### Getting Help
1. Check Flutter documentation
2. Review error messages carefully
3. Use `flutter doctor` to diagnose issues
4. Search Stack Overflow
5. Check GitHub issues

### Common Commands
```bash
flutter clean              # Clean build files
flutter pub get            # Get dependencies
flutter analyze            # Code analysis
flutter test              # Run tests
flutter build apk         # Build Android APK
```

---

**Last Updated:** January 2026  
**Version:** 1.0.0  
**Status:** Production Ready
