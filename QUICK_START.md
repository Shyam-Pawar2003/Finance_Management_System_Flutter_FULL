# Finance Management System - Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / Xcode
- A device or emulator

### Installation Steps

1. **Navigate to project directory:**
   ```bash
   cd Finance_Management_System_Flutter_FULL
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🔐 Login & Role Selection

### Step 1: Select Your Role
When you open the app, you'll see a login screen with a **Role Dropdown**. Choose one of:
- **Regular User** - Personal finance management
- **Company Authority** - Full company management
- **Employee** - Task and schedule tracking

### Step 2: Enter Credentials
- **Email:** Enter any email address (must contain @)
- **Password:** Enter any password (minimum 6 characters)

Example:
```
Email: test@company.com
Password: password123
Role: Company Authority
```

### Step 3: Login
Tap the **"Login"** button to proceed to your respective dashboard.

---

## 👤 Regular User Features

### Home Dashboard (Default view)
**4-Tab Navigation:**
1. **Dashboard** - Overview of finances
   - Welcome card
   - Financial summary (Balance, Income, Expense, Savings)
   - Recent transactions

2. **Add Transaction** - (Placeholder for adding new transactions)

3. **Transactions** - List of all transactions with amounts

4. **Profile** - User settings and preferences

### Features Available:
- View balance and spending
- Track income sources
- Monitor savings
- View transaction history
- Customize profile settings

---

## 🏢 Company Authority Features

### Dashboard Tab
- **Company Overview:** Key information about your company
- **KPI Cards:** Revenue ($2.5M), Loans, Profit, Active Projects
- **Activity Timeline:** Recent company activities

### Projects Tab
- **Ongoing Projects:** 8 active projects with progress tracking
- **Completed Projects:** 24 finished projects with budgets
- **Add Project Button:** Create new projects
- **📋 Manage Employee Tasks:** Assign daily tasks to employees

### Finance Tab
- **Revenue Overview:** Total earnings
- **Expense Tracking:** All company expenses
- **Profit Calculation:** Net profit after expenses
- **Active Loans:** 
  - National Bank: $300K at 6.5% interest
  - State Bank: $200K at 5.8% interest
- **Quarterly Performance:** Revenue trends (Q1-Q4)

### Employees Tab
- **Employee Statistics:**
  - Total Employees: 150
  - On Overtime: 12
  - On Leave: 8
  - New Hires: 5

- **Overtime Tracking:**
  - View overtime hours for each employee
  - Calculate overtime payments
  - Track work hours

- **Employee Roster:**
  - Complete employee list
  - Position and department info
  - Salary information
  - Join dates

---

## 📋 Task Management System

### How to Assign a Task

1. **Navigate to Projects Tab** in Company Management
2. **Tap "Manage Employee Tasks"** button (orange button)
3. **In Task Management Screen:**
   - Tap the **"+"** button to create new task
   
4. **Fill in Task Details:**
   - **Task Name:** e.g., "Fix Login Bug"
   - **Description:** Task details
   - **Assign to Employee:** Select from dropdown
   - **Project:** Choose which project this belongs to
   - **Priority:** Low, Medium, High, or Urgent
   - **Due Date:** Pick date from calendar

5. **Tap "Assign Task"** to save

### View Assigned Tasks
- See all tasks on the Task Management Screen
- Tasks are color-coded by priority
- Status shows "In Progress" or "Pending"
- Due dates are clearly displayed

---

## 👨‍💼 Employee Features

### Tasks Tab
- **Today's Tasks:** All tasks assigned for today
- **Task Progress:** Visual progress bars
- **Priority Levels:** High, Medium, Low tasks
- **Upcoming Tasks:** Next assignments scheduled

### Schedule Tab
- **Today's Status:** Check-in time and hours worked
- **Weekly Schedule:** Complete week overview
- **Overtime Hours:** Track extra hours worked
- **Leave Requests:** View and request time off

### Payment Tab
- **Monthly Salary:** Display of current salary ($5,000)
- **Earnings Breakdown:**
  - Base Salary
  - Overtime Pay
  - Bonuses
  - Deductions
- **Net Total:** Final payment amount
- **Payment History:** Previous 6+ months of payments

### Profile Tab
- **Employee Information:**
  - Employee ID
  - Department
  - Join Date
  - Contact Information

- **Quick Statistics:**
  - Projects completed
  - Tasks completed
  - Total overtime hours

- **Account Options:**
  - Change Password
  - Edit Profile
  - Help & Support

---

## 🎨 UI Navigation Guide

### Color Coding System
- **Green:** Regular user theme
- **Blue:** Company authority theme
- **Teal:** Employee theme
- **Red:** High priority / Urgent tasks
- **Orange:** Medium priority / Overtime
- **Green:** Low priority / Completed

### Button Types
- **Gradient Buttons:** Primary actions (Login, Assign)
- **Elevated Buttons:** Secondary actions (Add Project)
- **Text Buttons:** Tertiary actions (Register link)
- **Floating Action Button:** Quick actions (+)

### Navigation
- **Bottom Navigation Bar:** Main menu (on most screens)
- **AppBar Back Button:** Return to previous screen
- **Logout Icon:** Exit and return to login

---

## 🔧 Key Interactions

### Assigning a Task (Authority)
1. Navigate to Company → Projects Tab
2. Tap "Manage Employee Tasks"
3. Tap "+" button
4. Fill all required fields
5. Pick due date from calendar
6. Assign to employee
7. Tap "Assign Task"

### Viewing Employee Payment (Employee)
1. Navigate to My Tasks → Payment Tab
2. See monthly salary and earnings
3. View payment breakdown
4. Check payment history

### Editing Profile (User)
1. Navigate to Home → Profile Tab
2. Tap "Edit" button
3. Update fields
4. Save changes

---

## 📱 Screen Size Compatibility

The app works on:
- Mobile phones (4.5" - 6.5")
- Tablets (7" - 10")
- Landscape and portrait orientations
- Various screen densities (hdpi, xhdpi, xxhdpi)

---

## 🆘 Troubleshooting

### App Crashes on Login
- Ensure you selected a valid role
- Email must contain @ symbol
- Password must be at least 6 characters

### Tasks Not Appearing
- Ensure you're logged in as "Company Authority"
- Navigate to Projects Tab first
- Tap "Manage Employee Tasks"

### Payment Information Missing
- Login as "Employee" role
- Navigate to Payment Tab
- Check if you have assigned tasks

### TextEditingController Warnings
- This app properly disposes all controllers
- If you see warnings, rebuild the app (flutter clean && flutter pub get)

---

## 📊 Data Examples

### Sample Employee Data
```
Name: John Doe
Position: Senior Developer
Department: Development
Salary: $5,000/month
Overtime: 12 hours/week
Join Date: 2020-01-15
```

### Sample Project Data
```
Name: Mobile App Development
Client: ABC Corp
Progress: 65%
Team: 8 members
Deadline: 2025-03-30
```

### Sample Task Data
```
Task: Fix Login Bug
Priority: High
Assigned to: John Doe
Project: Mobile App Development
Due Date: 2025-01-30
Status: In Progress
```

---

## 💡 Tips & Tricks

1. **Quick Access:** Use the bottom navigation to switch between major sections
2. **Task Priority:** Red tasks are high priority, handle them first
3. **Payment Calculation:** Overtime is calculated at $37.50/hour
4. **Filtering:** Tasks are automatically sorted by due date
5. **Dark Mode:** App uses light theme optimized for readability

---

## 🔐 Security Notes

- Always use a strong password
- Logout before leaving your device
- Don't share your login credentials
- The app stores data locally (for now)
- Future versions will have cloud backup

---

## 📞 Support

For issues or feature requests:
1. Check the FEATURE_SUMMARY.md for complete documentation
2. Review the code comments in source files
3. Test with different roles to understand features better

---

## 🎯 Next Steps

1. **Explore all three roles** to understand different perspectives
2. **Try assigning tasks** as Company Authority
3. **View payments** as an Employee
4. **Test all features** before deployment

Enjoy managing your finances and company operations efficiently!
