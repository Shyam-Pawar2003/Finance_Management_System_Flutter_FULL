import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';

const List<String> dashboardRanges = ['Today', 'This Week', 'This Month'];

const List<NavItemData> dashboardNavItems = [
  NavItemData(label: 'Dashboard', icon: Icons.dashboard_rounded),
  NavItemData(label: 'Tasks', icon: Icons.task_alt_rounded),
  NavItemData(label: 'Attendance', icon: Icons.access_time_filled_rounded),
  NavItemData(label: 'Salary', icon: Icons.account_balance_wallet_rounded),
  NavItemData(label: 'Analytics', icon: Icons.insights_rounded),
  NavItemData(label: 'Calendar', icon: Icons.calendar_month_rounded),
];

const List<UserTask> dashboardTasks = [
  UserTask(
    title: 'Prepare monthly expense report',
    status: 'In Progress',
    dueDate: 'Today, 5:00 PM',
    priority: 'High',
  ),
  UserTask(
    title: 'Upload reimbursement receipts',
    status: 'Pending',
    dueDate: 'Mar 15',
    priority: 'Medium',
  ),
  UserTask(
    title: 'Client invoice cross-check',
    status: 'Completed',
    dueDate: 'Mar 10',
    priority: 'High',
  ),
  UserTask(
    title: 'Team standup notes submission',
    status: 'Pending',
    dueDate: 'Mar 16',
    priority: 'Low',
  ),
];

const List<QuickActionData> dashboardQuickActions = [
  QuickActionData(
    label: 'Apply Leave',
    icon: Icons.beach_access_rounded,
    color: Color(0xFF1A73E8),
  ),
  QuickActionData(
    label: 'Submit Report',
    icon: Icons.upload_file_rounded,
    color: Color(0xFF0F9D58),
  ),
  QuickActionData(
    label: 'View Payslip',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFFF29900),
  ),
  QuickActionData(
    label: 'Update Profile',
    icon: Icons.person_outline_rounded,
    color: Color(0xFF0F355B),
  ),
];

const List<UpcomingEvent> dashboardEvents = [
  UpcomingEvent(
    title: 'Payroll sync call',
    time: '11:30 AM',
    tag: 'Finance',
  ),
  UpcomingEvent(
    title: 'Quarterly planning review',
    time: '2:00 PM',
    tag: 'Planning',
  ),
  UpcomingEvent(
    title: '1:1 with manager',
    time: '4:30 PM',
    tag: 'People',
  ),
];

const List<AttendanceDay> dashboardAttendance = [
  AttendanceDay(day: 'Mon', value: 0.90),
  AttendanceDay(day: 'Tue', value: 0.95),
  AttendanceDay(day: 'Wed', value: 0.85),
  AttendanceDay(day: 'Thu', value: 0.93),
  AttendanceDay(day: 'Fri', value: 0.88),
];

const UserFinanceProfile seededUserProfile = UserFinanceProfile(
  name: 'John Doe',
  email: 'john.doe@example.com',
  currencyPreference: 'USD',
  twoFactorEnabled: true,
  biometricEnabled: false,
  bankImportEnabled: true,
);

const List<String> supportedCurrencies = [
  'USD',
  'EUR',
  'GBP',
  'INR',
  'AED',
];

const List<NavItemData> userDashboardSections = [
  NavItemData(label: 'Overview', icon: Icons.dashboard_customize_rounded),
  NavItemData(label: 'Profile', icon: Icons.person_outline_rounded),
  NavItemData(label: 'Income', icon: Icons.trending_up_rounded),
  NavItemData(label: 'Expenses', icon: Icons.receipt_long_rounded),
  NavItemData(label: 'Budgeting', icon: Icons.account_balance_wallet_rounded),
  NavItemData(label: 'Savings Goals', icon: Icons.savings_rounded),
  NavItemData(label: 'Investments', icon: Icons.candlestick_chart_rounded),
  NavItemData(label: 'Transactions', icon: Icons.swap_horiz_rounded),
  NavItemData(label: 'Calendar', icon: Icons.calendar_month_rounded),
  NavItemData(label: 'Reports', icon: Icons.analytics_outlined),
];

final List<IncomeRecord> seedIncomeRecords = [
  IncomeRecord(
    source: 'Salary',
    category: 'Fixed',
    amount: 5200,
    recordedOn: DateTime(2026, 3, 1),
    bankSynced: true,
  ),
  IncomeRecord(
    source: 'Freelance Project - UX Audit',
    category: 'Variable',
    amount: 1100,
    recordedOn: DateTime(2026, 3, 6),
    bankSynced: false,
  ),
  IncomeRecord(
    source: 'Dividend Payout',
    category: 'Investments',
    amount: 260,
    recordedOn: DateTime(2026, 3, 9),
    bankSynced: true,
  ),
  IncomeRecord(
    source: 'Consulting Session',
    category: 'Variable',
    amount: 420,
    recordedOn: DateTime(2026, 3, 12),
    bankSynced: false,
  ),
];

final List<ExpenseRecord> seedExpenseRecords = [
  ExpenseRecord(
    title: 'Apartment Rent',
    category: 'Rent',
    amount: 1450,
    spentOn: DateTime(2026, 3, 2),
    recurring: true,
    bankSynced: true,
  ),
  ExpenseRecord(
    title: 'Weekly Groceries',
    category: 'Food',
    amount: 185,
    spentOn: DateTime(2026, 3, 14),
    recurring: false,
    bankSynced: false,
  ),
  ExpenseRecord(
    title: 'Metro Pass',
    category: 'Transport',
    amount: 96,
    spentOn: DateTime(2026, 3, 10),
    recurring: true,
    bankSynced: true,
  ),
  ExpenseRecord(
    title: 'Streaming Subscription',
    category: 'Entertainment',
    amount: 18,
    spentOn: DateTime(2026, 3, 8),
    recurring: true,
    bankSynced: true,
  ),
  ExpenseRecord(
    title: 'Dining Out',
    category: 'Food',
    amount: 72,
    spentOn: DateTime(2026, 3, 15),
    recurring: false,
    bankSynced: false,
  ),
  ExpenseRecord(
    title: 'Phone Bill',
    category: 'Bills',
    amount: 48,
    spentOn: DateTime(2026, 3, 13),
    recurring: true,
    bankSynced: true,
  ),
];

const List<BudgetPlan> seedBudgetPlans = [
  BudgetPlan(
    cadence: 'Monthly',
    totalLimit: 3800,
    totalSpent: 3110,
    categories: [
      CategoryBudget(category: 'Food', limit: 550, spent: 487),
      CategoryBudget(category: 'Rent', limit: 1500, spent: 1450),
      CategoryBudget(category: 'Transport', limit: 180, spent: 132),
      CategoryBudget(category: 'Entertainment', limit: 260, spent: 211),
      CategoryBudget(category: 'Bills', limit: 380, spent: 312),
      CategoryBudget(category: 'Shopping', limit: 300, spent: 208),
    ],
  ),
  BudgetPlan(
    cadence: 'Weekly',
    totalLimit: 940,
    totalSpent: 782,
    categories: [
      CategoryBudget(category: 'Food', limit: 180, spent: 167),
      CategoryBudget(category: 'Transport', limit: 40, spent: 28),
      CategoryBudget(category: 'Entertainment', limit: 60, spent: 57),
      CategoryBudget(category: 'Bills', limit: 88, spent: 70),
      CategoryBudget(category: 'Shopping', limit: 75, spent: 62),
      CategoryBudget(category: 'Other', limit: 120, spent: 108),
    ],
  ),
];

final List<SavingsGoal> seedSavingsGoals = [
  SavingsGoal(
    name: 'Emergency Fund',
    targetAmount: 12000,
    currentAmount: 7400,
    targetDate: DateTime(2026, 12, 31),
    suggestedAutoTransfer: 420,
  ),
  SavingsGoal(
    name: 'Vacation - Japan',
    targetAmount: 4500,
    currentAmount: 1870,
    targetDate: DateTime(2026, 10, 20),
    suggestedAutoTransfer: 240,
  ),
  SavingsGoal(
    name: 'Retirement Booster',
    targetAmount: 25000,
    currentAmount: 9300,
    targetDate: DateTime(2027, 12, 31),
    suggestedAutoTransfer: 510,
  ),
];

const List<InvestmentHolding> seedInvestmentHoldings = [
  InvestmentHolding(
    assetName: 'S&P 500 ETF',
    assetType: 'Stocks',
    investedAmount: 6000,
    currentValue: 6725,
    riskLevel: 'Medium',
  ),
  InvestmentHolding(
    assetName: 'Global Tech Mutual Fund',
    assetType: 'Mutual Funds',
    investedAmount: 4200,
    currentValue: 4560,
    riskLevel: 'Medium',
  ),
  InvestmentHolding(
    assetName: 'Bitcoin',
    assetType: 'Crypto',
    investedAmount: 2100,
    currentValue: 1780,
    riskLevel: 'High',
  ),
  InvestmentHolding(
    assetName: 'US Treasury Bond ETF',
    assetType: 'Bonds',
    investedAmount: 2800,
    currentValue: 2875,
    riskLevel: 'Low',
  ),
];

const List<ReportSeriesPoint> seedMonthlyReportSeries = [
  ReportSeriesPoint(label: 'Apr', income: 5900, expense: 4020),
  ReportSeriesPoint(label: 'May', income: 6030, expense: 4210),
  ReportSeriesPoint(label: 'Jun', income: 6200, expense: 4180),
  ReportSeriesPoint(label: 'Jul', income: 6020, expense: 4065),
  ReportSeriesPoint(label: 'Aug', income: 6420, expense: 4370),
  ReportSeriesPoint(label: 'Sep', income: 6180, expense: 4250),
  ReportSeriesPoint(label: 'Oct', income: 6570, expense: 4510),
  ReportSeriesPoint(label: 'Nov', income: 6330, expense: 4460),
  ReportSeriesPoint(label: 'Dec', income: 7010, expense: 4690),
  ReportSeriesPoint(label: 'Jan', income: 6640, expense: 4520),
  ReportSeriesPoint(label: 'Feb', income: 6725, expense: 4485),
  ReportSeriesPoint(label: 'Mar', income: 6980, expense: 4710),
];
