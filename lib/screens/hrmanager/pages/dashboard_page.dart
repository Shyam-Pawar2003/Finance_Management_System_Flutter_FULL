import 'package:flutter/material.dart';

class HRDashboardPage extends StatelessWidget {
  const HRDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // copy the previous buildDashboard content or simplified version
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
}

// reuse TopCard and DashboardCard from original file; consider extracting them later
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
