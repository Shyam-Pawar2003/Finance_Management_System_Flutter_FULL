import 'package:flutter/material.dart';

/// Sidebar for HR manager with menu items and selection callback.
class HRSidebar extends StatelessWidget {
  const HRSidebar({
    Key? key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemTap,
  }) : super(key: key);

  final List<String> menuItems;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  onTap: () => onItemTap(index),
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
    );
  }

  IconData _getIcon(String title) {
    switch (title) {
      case "Dashboard":
        return Icons.dashboard;
      case "Inbox":
        return Icons.mail_outline;
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
