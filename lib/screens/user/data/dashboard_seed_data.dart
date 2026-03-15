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
