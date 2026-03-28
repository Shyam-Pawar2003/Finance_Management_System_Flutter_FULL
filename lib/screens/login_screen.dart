import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/role_model.dart';
import '../providers/auth_provider.dart';
import '../providers/rbac_provider.dart';
import 'user_dashboard.dart';
import 'subadmin_dashboard.dart';
import 'hr_dashboard.dart';
import 'finance_dashboard.dart';
import 'custom_dashboard.dart';
import 'NewUserAccountCreate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class ToggleButtonWidget extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const ToggleButtonWidget({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5A8DEE) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  bool isUserLogin = true;

  String selectedRole = "";

  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String _roleHelpText(String role) {
    switch (role) {
      case 'Normal User':
        return 'Best for daily personal finance usage and reports.';
      case 'Sub-admin':
        return 'For operational administration and staff coordination.';
      case 'HR Manager':
        return 'For people operations, leaves, and attendance tasks.';
      case 'Finance Manager':
        return 'For payroll, budgeting, and finance workflows.';
      case 'Custom Permission':
        return 'Use when your company configured a custom access profile.';
      default:
        return 'Select a role to continue.';
    }
  }

  @override
  void dispose() {
    companyIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF2),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 600),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F1C2E), Color(0xFF345D96)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "TECHCORP\nINDUSTRIES",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Text("Welcome Back!",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ToggleButtonWidget(
                            text: "USER LOGIN",
                            isActive: isUserLogin,
                            onTap: () {
                              setState(() {
                                isUserLogin = true;
                                selectedRole = "";
                              });
                            },
                          ),
                          const SizedBox(width: 20),
                          ToggleButtonWidget(
                            text: "COMPANY LOGIN",
                            isActive: !isUserLogin,
                            onTap: () {
                              setState(() {
                                isUserLogin = false;
                                selectedRole = "";
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: companyIdController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            isUserLogin ? Icons.email_outlined : Icons.business,
                          ),
                          labelText: isUserLogin ? "Email" : "Company ID",
                          border: const OutlineInputBorder(),
                          hintText: isUserLogin
                              ? "Enter your email"
                              : "Enter your company ID",
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: "Password",
                          border: const OutlineInputBorder(),
                          hintText: "Enter your password",
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Forgot password flow will be available soon.',
                                ),
                              ),
                            );
                          },
                          child: Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Select Role:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: isUserLogin
                                ? [
                                    RadioListTile(
                                      value: "Normal User",
                                      groupValue: selectedRole,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedRole = val!;
                                        });
                                      },
                                      title: const Text(
                                          "Normal User (Recommended)"),
                                    ),
                                  ]
                                : [
                                    RadioListTile(
                                      value: "Sub-admin",
                                      groupValue: selectedRole,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedRole = val!;
                                        });
                                      },
                                      title: const Text("Sub-admin"),
                                    ),
                                    RadioListTile(
                                      value: "HR Manager",
                                      groupValue: selectedRole,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedRole = val!;
                                        });
                                      },
                                      title: const Text("HR Manager"),
                                    ),
                                    RadioListTile(
                                      value: "Finance Manager",
                                      groupValue: selectedRole,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedRole = val!;
                                        });
                                      },
                                      title: const Text("Finance Manager"),
                                    ),
                                    RadioListTile(
                                      value: "Custom Permission",
                                      groupValue: selectedRole,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedRole = val!;
                                        });
                                      },
                                      title: const Text("Custom Permission"),
                                    ),
                                  ],
                          ),
                        ),
                      ),
                      if (selectedRole.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 18, color: Color(0xFF345D96)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _roleHelpText(selectedRole),
                                  style: const TextStyle(
                                    color: Color(0xFF345D96),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : login,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text("SECURE LOGIN"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const NewUserAccountCreate(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a role")),
      );
      return;
    }

    final email = companyIdController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(email: email, password: password);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login failed.')),
      );
      return;
    }

    final uid = auth.currentUser?.uid;
    if (uid != null) {
      final rbac = context.read<RbacProvider>();
      rbac.setCurrentUser(uid);
      final role = _mapRole(selectedRole);
      if (role != null) {
        rbac.assignRole(uid, role);
      }
    }

    if (selectedRole == "Normal User") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UserDashboard()));
    } else if (selectedRole == "Sub-admin") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SubAdminDashboard()));
    } else if (selectedRole == "HR Manager") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const HRDashboard()));
    } else if (selectedRole == "Finance Manager") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const FinanceDashboard()));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CustomDashboard()));
    }
  }

  String? _mapRole(String roleLabel) {
    switch (roleLabel) {
      case 'Sub-admin':
        return RoleNames.subAdmin;
      case 'HR Manager':
        return RoleNames.hrManager;
      case 'Finance Manager':
        return RoleNames.financeManager;
      case 'Normal User':
        return RoleNames.normalUser;
      default:
        return null;
    }
  }
}
