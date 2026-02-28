import 'package:flutter/material.dart';

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() =>
      _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (r) => false),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Projects'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return _buildProjects();
      case 2:
        return _buildFinance();
      case 3:
        return _buildEmployees();
      case 0:
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('TechCorp Industries',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Founded: 2015 | Employees: 150'),
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // RBAC summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Role-Based Access Control',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Sub-admin role\nHR Manager role\nFinance Manager role\nCustom permission control'),
              const SizedBox(height: 12),
              Row(children: [
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/roles'),
                    child: const Text('Manage Roles')),
                const SizedBox(width: 8),
                OutlinedButton(
                    onPressed: () {}, child: const Text('Learn more')),
              ])
            ]),
          ),
        ),

        const SizedBox(height: 16),
        const Text('Recent Activities',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text('New Project Started'),
            subtitle: const Text('Mobile App Development • Today')),
        ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Loan Approved'),
            subtitle:
                const Text('Business Expansion Loan - \$200K • Yesterday')),
      ]),
    );
  }

  Widget _buildProjects() {
    return Center(
        child: Text('Projects (placeholder)',
            style: const TextStyle(fontSize: 20)));
  }

  Widget _buildFinance() {
    return Center(
        child: Text('Finance (placeholder)',
            style: const TextStyle(fontSize: 20)));
  }

  Widget _buildEmployees() {
    return Center(
        child: Text('Employees (placeholder)',
            style: const TextStyle(fontSize: 20)));
  }
}
