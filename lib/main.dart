import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/company_management_screen.dart';
import 'screens/employee_task_screen.dart';
import 'screens/task_assignment_screen.dart';

void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financial Management System',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/company': (context) => const CompanyManagementScreen(),
        '/employee-tasks': (context) => const EmployeeTaskScreen(),
        '/task-assignment': (context) => const TaskAssignmentScreen(),
      },
    );
  }
}
