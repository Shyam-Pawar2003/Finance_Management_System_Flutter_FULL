import 'package:flutter/material.dart';

class UserDashboard  extends StatelessWidget {
  const UserDashboard ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          /// ================= SIDEBAR =================
          Container(
            width: 220,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 20),
                Text("Donezo",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 40),
                SidebarItem(icon: Icons.dashboard, title: "Dashboard"),
                SidebarItem(icon: Icons.task, title: "Tasks"),
                SidebarItem(icon: Icons.access_time, title: "Attendance"),
                SidebarItem(icon: Icons.attach_money, title: "Salary"),
                SidebarItem(icon: Icons.bar_chart, title: "Analytics"),
                SidebarItem(icon: Icons.calendar_today, title: "Calendar"),
              ],
            ),
          ),

          /// ================= MAIN CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Welcome, Shyam 👋",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.notifications_none, size: 28),
                          SizedBox(width: 20),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: Text("S"),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// SUMMARY CARDS
                  Row(
                    children: const [
                      SummaryCard(
                          title: "Total Assigned Tasks", value: "15"),
                      SizedBox(width: 20),
                      SummaryCard(title: "Completed Tasks", value: "10"),
                      SizedBox(width: 20),
                      SummaryCard(title: "Pending Tasks", value: "5"),
                      SizedBox(width: 20),
                      SummaryCard(title: "Leave Balance", value: "8 Days"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// MAIN GRID
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// LEFT COLUMN
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: const [
                            MyTasksCard(),
                            SizedBox(height: 20),
                            QuickActionsCard(),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      /// RIGHT COLUMN
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: const [
                            AttendanceCard(),
                            SizedBox(height: 20),
                            SalaryCard(),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

//// ================= WIDGETS =================


class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? routeName;     // Optional navigation
  final bool isSelected;       // Highlight active item
  final VoidCallback? onTap;   // Optional custom action

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.routeName,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.green;
    final Color defaultColor = Colors.grey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else if (widget.routeName != null &&
              ModalRoute.of(context)?.settings.name != widget.routeName) {
            Navigator.pushNamed(context, widget.routeName!);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? activeColor.withOpacity(0.12)
                : _isHovering
                    ? Colors.grey.withOpacity(0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected ? activeColor : defaultColor,
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      widget.isSelected ? activeColor : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const SummaryCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}

class MyTasksCard extends StatelessWidget {
  const MyTasksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return dashboardCard(
      title: "My Tasks",
      child: Column(
        children: const [
          TaskTile("Prepare Monthly Report", "Pending", Colors.orange),
          TaskTile("Client Meeting", "In Progress", Colors.blue),
          TaskTile("Submit Timesheet", "Completed", Colors.green),
        ],
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final String status;
  final Color color;

  const TaskTile(this.title, this.status, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(status, style: TextStyle(color: color)),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return dashboardCard(
      title: "Attendance",
      child: Column(
        children: const [
          SizedBox(height: 10),
          Text("94%",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Check-In: 09:00 AM"),
          Text("Check-Out: 06:00 PM"),
        ],
      ),
    );
  }
}

class SalaryCard extends StatelessWidget {
  const SalaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return dashboardCard(
      title: "Salary",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("\$4500",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Basic Pay: \$3500"),
          Text("Allowances: \$500"),
          Text("Deductions: \$500"),
        ],
      ),
    );
  }
}

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return dashboardCard(
      title: "Quick Actions",
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: const [
          ActionButton("Apply Leave", Icons.event),
          ActionButton("Submit Report", Icons.upload_file),
          ActionButton("View Payslip", Icons.receipt),
          ActionButton("Update Profile", Icons.person),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;

  const ActionButton(this.title, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8),
          Text(title)
        ],
      ),
    );
  }
}

Widget dashboardCard({required String title, required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2)
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        child
      ],
    ),
  );
}