import 'package:flutter/material.dart';
import 'Finance/DashboardFinancePage.dart';
import 'Finance/TransactionsPage.dart';
import 'Finance/PayrollPage.dart';
import 'Finance/InvoicesPage.dart';
import 'Finance/ReportsPage.dart';
import 'Finance/EmployeesFinancePage.dart';
import 'Finance/SettingsFinancePage.dart';

// Top-level main/MyApp removed; treat this file as a widget library only.

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    "Dashboard",
    "Transactions",
    "Payroll",
    "Invoices",
    "Reports",
    "Employees",
    "Settings"
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard,
    Icons.swap_horiz,
    Icons.account_balance_wallet,
    Icons.receipt_long,
    Icons.bar_chart,
    Icons.people,
    Icons.settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Row(
        children: [
          /// ================= SIDEBAR =================
          Container(
            width: 230,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                const Text(
                  "Finance Admin",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                ...List.generate(menuItems.length, (index) {
                  bool isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade50
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            menuIcons[index],
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            menuItems[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.blue : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          /// ================= MAIN CONTENT =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: getSelectedPage(),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= PAGE SWITCH =================
  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const DashboardFinancePage();
      case 1:
        return const TransactionsPage();
      case 2:
        return const PayrollPage();
      case 3:
        return const InvoicesPage();
      case 4:
        return const ReportsPage();
      case 5:
        return const EmployeesFinancePage();
      case 6:
        return const SettingsFinancePage();
      default:
        return const DashboardFinancePage();
    }
  }

  /// ================= DASHBOARD =================
  Widget buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Welcome, Shyam 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
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

        /// SUMMARY CARDS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            dashboardCard("Total Revenue", "₹ 4,50,000", Colors.green),
            dashboardCard("Total Expense", "₹ 2,10,000", Colors.red),
            dashboardCard("Net Profit", "₹ 2,40,000", Colors.blue),
            dashboardCard("Pending Payments", "₹ 75,000", Colors.orange),
          ],
        ),

        const SizedBox(height: 40),

        const Text(
          "Recent Transactions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                TransactionTile(
                  "Client Payment",
                  "Received",
                  "₹ 50,000",
                  Colors.green,
                ),
                TransactionTile(
                  "Office Rent",
                  "Paid",
                  "₹ 25,000",
                  Colors.red,
                ),
                TransactionTile(
                  "Software Subscription",
                  "Paid",
                  "₹ 10,000",
                  Colors.red,
                ),
                TransactionTile(
                  "Project Advance",
                  "Received",
                  "₹ 80,000",
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ================= DASHBOARD CARD =================
Widget dashboardCard(String title, String amount, Color color) {
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          amount,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

/// ================= TRANSACTION TILE =================
class TransactionTile extends StatelessWidget {
  final String title;
  final String status;
  final String amount;
  final Color color;

  const TransactionTile(this.title, this.status, this.amount, this.color,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(
          status == "Received" ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(status),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
cd C:\Users\shyam\Downloads\Finance_Management_System_Flutter_FULL

# If you haven't already committed your changes:
git add .
git commit -m "Initial import of finance flutter app"

# add the GitHub origin (replace with your username + repo name)
git remote add origin https://github.com/<your‑username>/<repo‑name>.git

# push the current branch (usually main or master)
git push -u origin main