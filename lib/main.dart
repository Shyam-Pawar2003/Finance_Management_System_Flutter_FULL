import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'screens/notifications_screen.dart';

import 'package:provider/provider.dart';
import 'package:finance_flutter_full/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/rbac_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/task_provider.dart';
import 'models/role_model.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
// Removed analysis/chatbot/market imports because those files are missing
// Restore or add them later if you want those routes back.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  final firebaseService = FirebaseService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<FirebaseService>.value(value: firebaseService),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(create: (_) => RbacProvider()),
        ChangeNotifierProvider(
          create: (context) => BudgetProvider(context.read<FirebaseService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              TransactionProvider(context.read<FirebaseService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => StockProvider(context.read<FirebaseService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              EmployeeProvider(context.read<FirebaseService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(context.read<FirebaseService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              NotificationProvider(context.read<FirebaseService>()),
        ),
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
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Indian Finance Manager',
          theme: theme.themeData,
          home: const _AuthGate(),
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
            '/notifications': (context) => const NotificationsScreen(),
            // analysis/chatbot/market routes removed (screens not present)
            '/company': (context) => Consumer<RbacProvider>(
                  builder: (context, rbac, _) {
                    final can = rbac.userHasRole(
                            rbac.currentUserId ?? '', RoleNames.subAdmin) ||
                        rbac.userHasRole(rbac.currentUserId ?? '',
                            RoleNames.companyAuthority);
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
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rbac = context.read<RbacProvider>();
    final tx = context.read<TransactionProvider>();
    final budget = context.read<BudgetProvider>();
    final stock = context.read<StockProvider>();
    final employees = context.read<EmployeeProvider>();
    final tasks = context.read<TaskProvider>();
    final notifications = context.read<NotificationProvider>();

    final uid = auth.currentUser?.uid;
    budget.bindToUser(uid);
    tx.bindToUser(uid);
    tx.registerBudgetProvider(budget);
    stock.bindToUser(uid);
    employees.bindToUser(uid);
    tasks.bindToUser(uid);
    notifications.bindToUser(uid);
    if (uid != null) {
      rbac.setCurrentUser(uid);
    }

    if (auth.isLoggedIn) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
