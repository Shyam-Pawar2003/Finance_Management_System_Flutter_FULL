import 'package:flutter/material.dart';

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
          Container(
            width: 240,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B5998), Color(0xFF2F4B7C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome,\nSarah!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          if (menuItems[index] == "Logout") {
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              selectedIndex = index;
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getIcon(menuItems[index]),
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                menuItems[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
    switch (menuItems[selectedIndex]) {
      case "Dashboard":
        return buildDashboard();
      default:
        return Center(
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

  /// ================= DASHBOARD UI =================
  Widget buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "HR Dashboard",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: const [
              Expanded(child: TopCard(title: "Total Employees", value: "245")),
              SizedBox(width: 20),
              Expanded(child: TopCard(title: "On Leave", value: "18")),
              SizedBox(width: 20),
              Expanded(child: TopCard(title: "New Hires", value: "6")),
              SizedBox(width: 20),
              Expanded(child: TopCard(title: "Open Positions", value: "4")),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: DashboardCard(
                  title: "Attendance Report",
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        "85%",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String title) {
    switch (title) {
      case "Dashboard":
        return Icons.dashboard;
      case "Employees":
        return Icons.people;
      case "Attendance":
        return Icons.access_time;
      case "Leave":
        return Icons.event_note;
      case "Recruitment":
        return Icons.work;
      case "Performance":
        return Icons.bar_chart;
      case "Reports":
        return Icons.receipt_long;
      case "Settings":
        return Icons.settings;
      case "Logout":
        return Icons.logout;
      default:
        return Icons.circle;
    }
  }
}

/// ================= TOP CARD =================
class TopCard extends StatelessWidget {
  final String title;
  final String value;

  const TopCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= DASHBOARD CARD =================
class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}
