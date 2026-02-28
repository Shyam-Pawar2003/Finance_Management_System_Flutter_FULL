import 'package:flutter/material.dart';

// Removed main() and MyApp; this file should only export the
// CustomDashboard widget which is used inside the main app.

class CustomDashboard extends StatefulWidget {
  const CustomDashboard({super.key});

  @override
  State<CustomDashboard> createState() => _CustomDashboardState();
}

class _CustomDashboardState extends State<CustomDashboard> {
  int selectedIndex = 0;

  String userRole = "Admin"; // Admin / Manager / Employee

  List<String> getMenuItems() {
    if (userRole == "Admin") {
      return ["Dashboard", "Users", "Reports", "Settings"];
    } else if (userRole == "Manager") {
      return ["Dashboard", "Team", "Reports"];
    } else {
      return ["Dashboard", "My Tasks"];
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = getMenuItems();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Row(
        children: [
          /// ================= SIDEBAR =================
          Container(
            width: 220,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                const Text(
                  "Custom Dashboard",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Role: $userRole",
                    style: const TextStyle(color: Colors.grey)),
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
                          Icon(Icons.circle,
                              size: 10,
                              color: isSelected ? Colors.blue : Colors.grey),
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

                const Spacer(),

                /// Switch Role Button
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (userRole == "Admin") {
                          userRole = "Manager";
                        } else if (userRole == "Manager") {
                          userRole = "Employee";
                        } else {
                          userRole = "Admin";
                        }
                        selectedIndex = 0;
                      });
                    },
                    child: const Text("Switch Role"),
                  ),
                )
              ],
            ),
          ),

          /// ================= MAIN CONTENT =================
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: getSelectedPage(menuItems[selectedIndex]),
            ),
          )
        ],
      ),
    );
  }

  /// ================= PAGE SWITCHING LOGIC =================
  Widget getSelectedPage(String menu) {
    switch (menu) {
      case "Dashboard":
        return const DashboardPage();
      case "Users":
        return const UsersPage();
      case "Reports":
        return const ReportsPage();
      case "Settings":
        return const SettingsPage();
      case "Team":
        return const TeamPage();
      case "My Tasks":
        return const MyTasksPage();
      default:
        return const DashboardPage();
    }
  }
}

//// ====================== PAGES ======================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Dashboard Page",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Users Page",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Reports Page",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool notificationsEnabled = true;

  final TextEditingController nameController =
      TextEditingController(text: "Shyam Pawar");

  final TextEditingController emailController =
      TextEditingController(text: "shyam@email.com");

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Settings",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          /// ================= PROFILE SECTION =================
          sectionCard(
            title: "Profile Information",
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// ================= PASSWORD SECTION =================
          sectionCard(
            title: "Change Password",
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// ================= PREFERENCES =================
          sectionCard(
            title: "Preferences",
            child: Column(
              children: [
                SwitchListTile(
                  value: darkMode,
                  onChanged: (val) {
                    setState(() {
                      darkMode = val;
                    });
                  },
                  title: const Text("Dark Mode"),
                ),
                SwitchListTile(
                  value: notificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      notificationsEnabled = val;
                    });
                  },
                  title: const Text("Enable Notifications"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ================= SAVE BUTTON =================
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: saveSettings,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Save Changes"),
            ),
          )
        ],
      ),
    );
  }

  /// ================= SAVE FUNCTION =================
  void saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Settings Saved Successfully!"),
      ),
    );
  }
}

/// ================= REUSABLE CARD =================
Widget sectionCard({
  required String title,
  required Widget child,
}) {
  return Container(
    width: 600,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Team Page",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}

class MyTasksPage extends StatelessWidget {
  const MyTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("My Tasks Page",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}
