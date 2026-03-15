import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/company_management_screen.dart';
import 'screens/employee_task_screen.dart';
import 'screens/task_assignment_screen.dart';
import 'screens/unauthorized_screen.dart';
import 'screens/role_switcher_screen.dart';

import 'package:provider/provider.dart';
import 'providers/rbac_provider.dart';
import 'providers/theme_provider.dart';
import 'models/role_model.dart';
// Removed analysis/chatbot/market imports because those files are missing
// Restore or add them later if you want those routes back.

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RbacProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const FinanceApp(),
    ),
  );
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Indian Finance Manager',
      theme: theme.themeData,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => Consumer<RbacProvider>(
              builder: (context, rbac, _) {
                // finance managers and sub-admins can access dashboard
                final can = rbac.userHasRole(
                        rbac.currentUserId ?? '', RoleNames.subAdmin) ||
                    rbac.userHasRole(
                        rbac.currentUserId ?? '', RoleNames.financeManager);
                return can
                    ? const DashboardScreen()
                    : const UnauthorizedScreen();
              },
            ),
        '/profile': (context) => const UserProfileScreen(),
        // analysis/chatbot/market routes removed (screens not present)
        '/company': (context) => Consumer<RbacProvider>(
              builder: (context, rbac, _) {
                final can = rbac.userHasRole(
                        rbac.currentUserId ?? '', RoleNames.subAdmin) ||
                    rbac.userHasRole(
                        rbac.currentUserId ?? '', RoleNames.companyAuthority);
                return can
                    ? const CompanyManagementScreen()
                    : const UnauthorizedScreen();
              },
            ),
        '/employee-tasks': (context) => Consumer<RbacProvider>(
              builder: (context, rbac, _) {
                final can = rbac.userHasRole(
                        rbac.currentUserId ?? '', RoleNames.subAdmin) ||
                    rbac.userHasRole(
                        rbac.currentUserId ?? '', RoleNames.hrManager);
                return can
                    ? const EmployeeTaskScreen()
                    : const UnauthorizedScreen();
              },
            ),
        '/task-assignment': (context) => const TaskAssignmentScreen(),
        '/roles': (context) => const RoleSwitcherScreen(),
      },
    );
  }
}
