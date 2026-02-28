import 'package:flutter/material.dart';
import 'toggle_button.dart';
import 'user_dashboard.dart';
import 'subadmin_dashboard.dart';
import 'hr_dashboard.dart';
import 'finance_dashboard.dart';
import 'custom_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isUserLogin = true;

  String selectedRole = "";

  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                          prefixIcon: const Icon(Icons.business),
                          labelText: "Company ID",
                          border: const OutlineInputBorder(),
                          hintText: "Enter your company ID",
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
                      const Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: null,
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
                                      title: const Text("Normal User"),
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
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: login,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text("SECURE LOGIN"),
                          ),
                        ),
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

  void login() {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text("Please select a role")),
      );
      return;
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
}
