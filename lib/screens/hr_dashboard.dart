import 'package:flutter/material.dart';
import '../Dashboard/Admin/Inbox_Page.dart' as hr_inbox;
import 'hrmanager/sidebar.dart';
import 'hrmanager/pages/dashboard_page.dart';
import 'hrmanager/pages/employees_page.dart' as hr_employees;
import 'hrmanager/pages/attendance_page.dart' as hr_attendance;
import 'hrmanager/pages/leave_page.dart' as hr_leave;
import 'hrmanager/pages/recruitment_page.dart' as hr_recruitment;
import 'hrmanager/pages/performance_page.dart' as hr_performance;
import 'hrmanager/pages/reports_page.dart' as hr_reports;
import 'hrmanager/pages/settings_page.dart' as hr_settings;

// Removed top-level `main` and `MyApp` wrapper.  This file only defines
// the `HRDashboard` widget; the application is started from lib/main.dart.
// Having multiple `runApp` calls on web leads to runtime errors like
// "Cannot read properties of undefined (reading 'AxisDirection')" or
// `Colors` being undefined.

class HRDashboard extends StatefulWidget {
  const HRDashboard({super.key});

  @override
  State<HRDashboard> createState() => _HRDashboardState();
}

class _HRDashboardState extends State<HRDashboard> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    "Dashboard",
    "Inbox",
    "Employees",
    "Attendance",
    "Leave",
    "Recruitment",
    "Performance",
    "Reports",
    "Settings",
    "Logout"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F4B7C),
      body: Row(
        children: [
          /// ================= SIDEBAR =================
          HRSidebar(
            menuItems: menuItems,
            selectedIndex: selectedIndex,
            onItemTap: (index) {
              if (menuItems[index] == "Logout") {
                Navigator.pop(context);
              } else {
                setState(() {
                  selectedIndex = index;
                });
              }
            },
          ),

          /// ================= MAIN AREA =================
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                ),
              ),
              child: getSelectedPage(),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= PAGE SWITCHING =================
  Widget getSelectedPage() {
    final pages = <String, Widget>{
      'Dashboard': const HRDashboardPage(),
      'Inbox': const hr_inbox.InboxPage(),
      'Employees': const hr_employees.EmployeesPage(),
      'Attendance': const hr_attendance.AttendancePage(),
      'Leave': const hr_leave.LeavePage(),
      'Recruitment': const hr_recruitment.RecruitmentPage(),
      'Performance': const hr_performance.PerformancePage(),
      'Reports': const hr_reports.ReportsPage(),
      'Settings': const hr_settings.SettingsPage(),
    };

    return pages[menuItems[selectedIndex]] ??
        Center(
          child: Text(
            "${menuItems[selectedIndex]} Page",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
  }
}
