import 'package:flutter/material.dart';
// relative path from screens directory to Dashboard/Admin
import '../Dashboard/Admin/Inbox_Page.dart';
import '../Dashboard/Admin/calendar_page.dart';
// calendar page implementation imported above (spelling corrected)

class SubAdminDashboard extends StatefulWidget {
  const SubAdminDashboard({super.key});

  @override
  State<SubAdminDashboard> createState() => _SubAdminDashboardState();
}

class _SubAdminDashboardState extends State<SubAdminDashboard> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    "Dashboard",
    "Inbox",
    "Calendar",
    "Employees",
    "Attendance",
    "Performance",
    "Payroll",
    "Leave Management",
    "Recruitment",
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard_outlined,
    Icons.mail_outline,
    Icons.calendar_today_outlined,
    Icons.people_outline,
    Icons.access_time,
    Icons.show_chart,
    Icons.account_balance_wallet_outlined,
    Icons.event_note_outlined,
    Icons.search,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Row(
        children: [
          /// ================= SIDEBAR =================
          Container(
            width: 240,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Sub Admin Panel",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                ...List.generate(menuItems.length, (index) {
                  bool active = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 6),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF36B39C)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            menuIcons[index],
                            color: active ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            menuItems[index],
                            style: TextStyle(
                              color: active ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "© 2026 Company",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
          ),

          /// ================= MAIN CONTENT =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: _buildContent(),
            ),
          )
        ],
      ),
    );
  }

  /// ================= PAGE SWITCH =================
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardContent();

      case 1:
        return const InboxPage();

      case 2:
        // show actual calendar page
        return const CalendarPage();

      case 3:
        return const Center(child: Text("Employees Page"));

      case 4:
        return const Center(child: Text("Attendance Page"));

      case 5:
        return const Center(child: Text("Performance Page"));

      case 6:
        return const Center(child: Text("Payroll Page"));

      case 7:
        return const Center(child: Text("Leave Management Page"));

      case 8:
        return const Center(child: Text("Recruitment Page"));

      default:
        return _buildDashboardContent();
    }
  }

  /// ================= DASHBOARD PAGE =================
  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Welcome, Shyam 👋",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Row(
              children: const [
                Icon(Icons.notifications_none, size: 28),
                SizedBox(width: 15),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                )
              ],
            )
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            dashboardCard("Total Employees", "45", Colors.blue),
            dashboardCard("Tasks Assigned", "120", Colors.orange),
            dashboardCard("Completed Tasks", "95", Colors.green),
          ],
        ),
        const SizedBox(height: 40),
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView(
              children: const [
                ActivityTile("Task assigned to Rahul", "2 hours ago"),
                ActivityTile("Employee added", "Today"),
                ActivityTile("Monthly report generated", "Yesterday"),
              ],
            ),
          ),
        )
      ],
    );
  }
}

/// ================= DASHBOARD CARD =================
Widget dashboardCard(String title, String value, Color color) {
  return Container(
    width: 220,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    ),
  );
}

/// ================= ACTIVITY TILE =================
class ActivityTile extends StatelessWidget {
  final String title;
  final String time;

  const ActivityTile(this.title, this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE3F2FD),
        child: Icon(Icons.notifications, color: Colors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(time),
    );
  }
}
