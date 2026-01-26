# App Flow & User Journey Guide

## 🗺️ Complete App Navigation Map

```
┌─────────────────────────────────────────────────────────────────┐
│                        FINANCE MANAGEMENT SYSTEM                 │
│                    Complete Navigation Flow                      │
└─────────────────────────────────────────────────────────────────┘

                         ┌──────────────┐
                         │ LOGIN SCREEN │
                         └──────┬───────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
                    │           │           │
         ┌──────────▼──┐  ┌──────▼──────┐  ┌──────────▼────┐
         │  REGISTER   │  │  SELECT     │  │   REMEMBER:   │
         │  SCREEN     │  │  ROLE       │  │   email @ req │
         │             │  │  DROPDOWN   │  │   pwd 6+ chars│
         │ (Optional)  │  │             │  └───────────────┘
         └─────────────┘  └──────┬──────┘
                                  │
                  ┌───────────────┼───────────────┐
                  │               │               │
                  │               │               │
         ┌────────▼─────┐ ┌──────▼──────┐ ┌────────▼──────┐
         │  REGULAR     │ │  COMPANY    │ │   EMPLOYEE    │
         │  USER        │ │  AUTHORITY  │ │   DASHBOARD   │
         │  DASHBOARD   │ │  DASHBOARD  │ │               │
         └────────┬─────┘ └──────┬──────┘ └────────┬───────┘
                  │              │                  │
                  │              │                  │
         ┌────────▼─────┐ ┌──────▼──────┐ ┌────────▼───────┐
         │ 4 TABS:      │ │ 4 TABS:     │ │ 4 TABS:        │
         │ • Dashboard  │ │ • Dashboard │ │ • Tasks        │
         │ • Add Txn    │ │ • Projects  │ │ • Schedule     │
         │ • Txns       │ │ • Finance   │ │ • Payment      │
         │ • Profile    │ │ • Employees │ │ • Profile      │
         └─────────────┘ └──────┬──────┘ └────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
         ┌──────────▼────────────┐ ┌────────▼──────────────┐
         │ TASK ASSIGNMENT      │ │ OTHER SCREENS:       │
         │ SCREEN               │ │ • Financial Analytics │
         │ (Add/View Tasks)     │ │ • User Profile       │
         └──────────────────────┘ └──────────────────────┘
```

---

## 👤 Regular User Journey

```
REGULAR USER FLOW
─────────────────

Step 1: Login
├─ Select Role: "Regular User"
├─ Enter Email: user@example.com
├─ Enter Password: password123
└─ Tap "Login"

Step 2: Home Dashboard (Default)
├─ View 4 Tabs:
│  ├─ Dashboard Tab
│  │  ├─ Welcome Message
│  │  ├─ Financial Summary Cards
│  │  │  ├─ Balance
│  │  │  ├─ Income
│  │  │  ├─ Expense
│  │  │  └─ Savings
│  │  └─ Recent Transactions
│  │
│  ├─ Add Transaction Tab
│  │  └─ Form to add new transaction
│  │
│  ├─ Transactions Tab
│  │  ├─ List of all transactions
│  │  ├─ Transaction dates
│  │  └─ Transaction amounts
│  │
│  └─ Profile Tab
│     ├─ User Avatar
│     ├─ User Settings
│     ├─ Notification Settings
│     └─ Logout Button

Step 3: Explore Financial Analytics
├─ Tap on Dashboard screen
├─ View:
│  ├─ Spending by Category
│  │  ├─ Groceries (36%)
│  │  ├─ Entertainment (26%)
│  │  ├─ Utilities (22%)
│  │  └─ Transport (16%)
│  ├─ Budget Progress
│  │  ├─ Monthly Budget Progress
│  │  └─ Emergency Fund Status
│  └─ Quarterly Performance

Step 4: Edit Profile
├─ Go to Profile Tab
├─ Tap "Edit" button
├─ Update:
│  ├─ Name
│  ├─ Email
│  ├─ Phone
│  └─ Location
└─ Save Changes

Step 5: Logout
└─ Tap Logout Button
   └─ Returns to Login Screen
```

---

## 🏢 Company Authority Journey

```
COMPANY AUTHORITY FLOW
──────────────────────

Step 1: Login
├─ Select Role: "Company Authority"
├─ Enter Email: admin@company.com
├─ Enter Password: password123
└─ Tap "Login"

Step 2: Company Management Dashboard
├─ View 4 Tabs:
│
│  Tab 1: DASHBOARD
│  ├─ Company Overview Card
│  │  ├─ Company Name
│  │  ├─ Founded Year
│  │  └─ Total Employees
│  ├─ KPI Metric Cards
│  │  ├─ Revenue: $2.5M
│  │  ├─ Loans: $500K
│  │  ├─ Profit: $750K
│  │  └─ Active Projects: 12
│  └─ Recent Activity Timeline
│
│  Tab 2: PROJECTS
│  ├─ "Manage Employee Tasks" Button
│  │  └─ Opens Task Assignment Screen
│  ├─ Ongoing Projects (8)
│  │  ├─ Mobile App Development (65%)
│  │  ├─ Web Dashboard (45%)
│  │  ├─ Cloud Migration (80%)
│  │  └─ ...more projects
│  └─ Completed Projects (24)
│     ├─ E-Commerce Platform
│     ├─ Inventory Management
│     └─ ...more projects
│
│  Tab 3: FINANCE
│  ├─ Revenue Overview
│  ├─ Expense Tracking
│  ├─ Profit Calculation
│  ├─ Active Loans
│  │  ├─ National Bank: $300K @ 6.5%
│  │  └─ State Bank: $200K @ 5.8%
│  └─ Quarterly Performance (Q1-Q4)
│
│  Tab 4: EMPLOYEES
│  ├─ Employee Statistics
│  │  ├─ Total: 150
│  │  ├─ On Overtime: 12
│  │  ├─ On Leave: 8
│  │  └─ New Hires: 5
│  ├─ Overtime Tracking
│  │  ├─ John Doe: 12 hrs ($450)
│  │  ├─ Sarah Smith: 8 hrs ($320)
│  │  └─ Mike Johnson: 10 hrs ($380)
│  └─ Full Employee Roster

Step 3: Manage Tasks
├─ In Projects Tab, Tap "Manage Employee Tasks"
├─ Task Assignment Screen Opens
├─ Create New Task:
│  ├─ Tap "+" Button
│  ├─ Fill Dialog:
│  │  ├─ Task Name: "Fix Login Bug"
│  │  ├─ Description: "..."
│  │  ├─ Assign to: Select Employee
│  │  ├─ Project: Select Project
│  │  ├─ Priority: Select (Low/Med/High/Urgent)
│  │  └─ Due Date: Pick from Calendar
│  └─ Tap "Assign Task"
│
├─ View Assigned Tasks
│  ├─ See All Tasks Summary
│  │  ├─ Total Tasks
│  │  ├─ In Progress
│  │  └─ Pending
│  └─ View Individual Tasks
│     ├─ Task Name & Priority
│     ├─ Assigned Employee
│     ├─ Project Name
│     ├─ Status
│     └─ Due Date

Step 4: Monitor Finance
├─ Go to Finance Tab
├─ View:
│  ├─ Annual Revenue: $2.5M
│  ├─ Total Expenses: $1.75M
│  ├─ Net Profit: $750K
│  ├─ Active Loans with:
│  │  ├─ Bank Name
│  │  ├─ Loan Amount
│  │  ├─ Interest Rate
│  │  ├─ Monthly Payment
│  │  └─ Remaining Balance
│  └─ Quarterly Performance Chart

Step 5: Track Employees
├─ Go to Employees Tab
├─ View Statistics:
│  ├─ Employee Count by Status
│  ├─ Overtime Hours Tracking
│  └─ Leave Management
└─ Access Employee Roster

Step 6: Logout
└─ Tap Logout
   └─ Returns to Login Screen
```

---

## 👨‍💼 Employee Journey

```
EMPLOYEE FLOW
─────────────

Step 1: Login
├─ Select Role: "Employee"
├─ Enter Email: john.doe@company.com
├─ Enter Password: password123
└─ Tap "Login"

Step 2: Employee Dashboard
├─ View 4 Tabs:
│
│  Tab 1: TASKS
│  ├─ Task Summary Cards
│  │  ├─ Total Tasks: 15
│  │  ├─ Completed: 8
│  │  └─ Pending: 7
│  ├─ Today's Tasks Section
│  │  ├─ Task with Progress Bar
│  │  ├─ Task Priority (High/Med/Low)
│  │  ├─ Due Time
│  │  └─ Task Status
│  └─ Upcoming Tasks
│     ├─ Task Name & Date
│     ├─ Time Scheduled
│     └─ Task Type (Meeting/Deadline)
│
│  Tab 2: SCHEDULE
│  ├─ Today's Status Card
│  │  ├─ Check-in Time: 9:00 AM
│  │  ├─ Hours Worked: 6.5
│  │  └─ Current Status: Working
│  ├─ Weekly Schedule
│  │  ├─ Monday: 8 hours (Normal)
│  │  ├─ Tuesday: 9 hours (Overtime)
│  │  ├─ Wednesday: 8 hours (Normal)
│  │  ├─ Thursday: 10 hours (Overtime)
│  │  ├─ Friday: 8 hours (Normal)
│  │  └─ Saturday: 6 hours (Half Day)
│  └─ Leave Requests
│     ├─ Annual Leave (Pending)
│     └─ Sick Leave (Approved)
│
│  Tab 3: PAYMENT
│  ├─ Monthly Salary Card
│  │  ├─ Salary: $5,000
│  │  └─ Next Payment: Feb 1
│  ├─ Earnings Breakdown
│  │  ├─ Base Salary: $5,000
│  │  ├─ Overtime Pay: $450
│  │  ├─ Bonus: $200
│  │  └─ Deductions: -$650
│  ├─ Net Total: $5,000
│  └─ Payment History (Last 6+ months)
│
│  Tab 4: PROFILE
│  ├─ Employee Photo
│  ├─ Personal Information
│  │  ├─ Name: John Doe
│  │  ├─ Position: Senior Developer
│  │  ├─ Department: Development
│  │  ├─ Employee ID: EMP-12345
│  │  ├─ Email: john.doe@company.com
│  │  ├─ Phone: +1-234-567-8900
│  │  └─ Join Date: Jan 15, 2020
│  ├─ Quick Statistics
│  │  ├─ Projects: 8
│  │  ├─ Tasks Done: 124
│  │  └─ Overtime: 28 hrs
│  └─ Account Options
│     ├─ Change Password
│     ├─ Edit Profile
│     └─ Help & Support

Step 3: View Assigned Tasks
├─ Go to Tasks Tab
├─ See Today's Tasks
├─ View Task Details:
│  ├─ Task Name
│  ├─ Priority Level
│  ├─ Project Assigned To
│  ├─ Progress Bar
│  ├─ Due Time
│  └─ Status
└─ Check Upcoming Tasks

Step 4: Monitor Work Hours
├─ Go to Schedule Tab
├─ Check Today's Status:
│  ├─ Check-in time
│  ├─ Hours worked so far
│  └─ Current work status
├─ View Weekly Schedule
├─ See Overtime Hours
└─ Check Leave Requests

Step 5: Review Payment
├─ Go to Payment Tab
├─ View Monthly Salary: $5,000
├─ Check Earnings:
│  ├─ Base: $5,000
│  ├─ Overtime: $450 (12 hours @ $37.50/hr)
│  ├─ Bonus: $200
│  └─ Deductions: -$650
├─ See Net Total: $5,000
└─ Check Payment History

Step 6: Update Profile
├─ Go to Profile Tab
├─ Review Employee Info
├─ Tap "Edit" if Available
├─ Update Information
└─ Save Changes

Step 7: Logout
└─ Tap Logout
   └─ Returns to Login Screen
```

---

## 🔀 Task Assignment Workflow (Authority Only)

```
DETAILED TASK ASSIGNMENT PROCESS
─────────────────────────────────

1. NAVIGATE TO TASK MANAGEMENT
   Company Management Screen
   └─ Projects Tab
      └─ Tap "Manage Employee Tasks"
         └─ Task Assignment Screen Opens

2. CREATE NEW TASK
   Tap "+" (Floating Action Button)
   └─ Dialog Opens

3. FILL TASK DETAILS
   ├─ Task Name (Required)
   │  └─ "Fix Login Bug"
   │
   ├─ Description (Optional)
   │  └─ "Fix the login validation issue"
   │
   ├─ Select Employee (Dropdown)
   │  ├─ John Doe - Senior Developer
   │  ├─ Sarah Smith - Frontend Developer
   │  ├─ Mike Johnson - Backend Developer
   │  └─ Emily Davis - QA Engineer
   │
   ├─ Select Project (Dropdown)
   │  ├─ Mobile App Development
   │  ├─ Web Dashboard
   │  ├─ Cloud Migration
   │  └─ AI Implementation
   │
   ├─ Select Priority (Dropdown)
   │  ├─ Low (Green)
   │  ├─ Medium (Orange)
   │  ├─ High (Red)
   │  └─ Urgent (Deep Orange)
   │
   └─ Pick Due Date (Calendar)
      └─ Select date from calendar picker

4. SUBMIT TASK
   Tap "Assign Task" Button
   └─ Task is Added to List

5. VIEW ASSIGNED TASKS
   ├─ Summary Cards Show:
   │  ├─ Total Tasks: X
   │  ├─ In Progress: Y
   │  └─ Pending: Z
   │
   └─ Task List Shows:
      ├─ Task Name
      ├─ Assigned Employee
      ├─ Project
      ├─ Priority (Color-Coded)
      ├─ Status
      └─ Due Date

6. MANAGE TASKS
   ├─ View task details
   ├─ Change task status
   ├─ Update priority if needed
   └─ Track completion
```

---

## 📱 Screen Transition Diagram

```
                    ┌──────────────┐
                    │ Login Screen │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ Registration │◄──┐
                    │   Screen     │   │
                    └──────┬───────┘   │
                           │          │
                    ┌──────▼────────────┘
                    │
           ┌────────▼────────┐
           │  Role Selected  │
           └────┬───┬───┬────┘
               │   │   │
    ┌──────────┘   │   └──────────┐
    │              │              │
    │              │              │
┌───▼──────────┐   │      ┌───────▼──────┐
│ Regular User │   │      │   Employee   │
│  Dashboard   │   │      │  Dashboard   │
└───┬──────────┘   │      └───────┬──────┘
    │              │              │
    │         ┌────▼─────────┐    │
    │         │   Company    │    │
    │         │  Authority   │    │
    │         │  Dashboard   │    │
    │         └────┬─────────┘    │
    │              │              │
    │         ┌────▼──────────┐   │
    │         │     Task      │   │
    │         │ Assignment    │   │
    │         │   Screen      │   │
    │         └───────────────┘   │
    │                             │
    │      ┌──────────┬──────────┐│
    │      │          │          ││
┌───▼──┐ ┌─▼──┐ ┌────▼──┐  ┌───▼┐
│      │ │    │ │       │  │    │
│      │ │    │ │       │  │    │
│Logout│ │Dash│ │Profile│  │Anly│
│      │ │    │ │       │  │tics│
│      │ │    │ │       │  │    │
└──────┘ └────┘ └────────┘  └────┘

(All paths lead back to Login on Logout)
```

---

## 🎯 Key Navigation Points

### From Any Screen
```
Login Screen
├─ Always accessible via Logout
├─ Role selection for all users
└─ Registration option available

Home Screens (Dashboards)
├─ Bottom navigation bar for tabs
├─ Multiple sections accessible
└─ Logout button in AppBar

Secondary Screens
├─ Back button for navigation
├─ AppBar with title
└─ Navigation within tabs
```

---

## 🔐 Permission Matrix

```
FEATURE                 REGULAR USER    AUTHORITY    EMPLOYEE
────────────────────────────────────────────────────────────
View Dashboard          ✅              ✅           ✅
Edit Profile            ✅              ❌           ✅
View Transactions       ✅              ❌           ❌
Financial Analytics     ✅              ✅           ❌
View Company Info       ❌              ✅           ❌
View Projects           ❌              ✅           ❌
View Finance            ❌              ✅           ❌
Assign Tasks            ❌              ✅           ❌
View Assigned Tasks     ❌              ❌           ✅
View Payment Info       ❌              ❌           ✅
View Employees          ❌              ✅           ❌
View Overtime           ❌              ✅           ✅
Edit Employee Data      ❌              ✅           ❌
```

---

## ⏱️ User Interaction Timelines

### Typical Regular User Session (10-15 minutes)
```
0:00  - Login
0:30  - View Home Dashboard
1:00  - Check Financial Analytics
2:30  - View Transactions
4:00  - Update Profile
8:00  - Explore Settings
10:00 - Logout
```

### Typical Authority Session (20-30 minutes)
```
0:00  - Login
0:30  - View Company Dashboard
2:00  - Check Projects
5:00  - Review Finance
8:00  - Check Employees
12:00 - Assign Tasks (5-10 minutes)
20:00 - Review Task Assignments
25:00 - Logout
```

### Typical Employee Session (5-10 minutes)
```
0:00  - Login
0:30  - View Assigned Tasks
2:00  - Check Schedule
3:30  - Review Payment
5:00  - Update Profile Info
7:00  - Logout
```

---

## 🎨 Visual Navigation Cues

### Color Coding
- **Green Elements** → Regular User Interface
- **Blue Elements** → Company Authority Interface
- **Teal Elements** → Employee Interface
- **Red** → High Priority / Urgent
- **Orange** → Medium Priority / Overtime
- **Green Checkmark** → Completed

### Icon Guide
- 📊 Dashboard
- 📝 Transactions/Tasks
- 👤 Profile
- 🏢 Company
- 💰 Finance
- 👥 Employees
- 📅 Schedule
- 💸 Payment
- ➕ Add/New
- 🚪 Logout

---

This comprehensive guide helps users and developers understand the complete flow and navigation structure of the Finance Management System.
