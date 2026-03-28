import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/role_model.dart';
import '../providers/auth_provider.dart';
import '../providers/rbac_provider.dart';
import 'login_screen.dart';

class NewUserAccountCreate extends StatefulWidget {
  const NewUserAccountCreate({super.key});

  @override
  State<NewUserAccountCreate> createState() => _NewUserAccountCreateState();
}

class _NewUserAccountCreateState extends State<NewUserAccountCreate> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedRole;
  bool _isCreating = false;

  final List<String> roles = const [
    RoleNames.normalUser,
    RoleNames.superAdmin,
    RoleNames.subAdmin,
    RoleNames.hrManager,
    RoleNames.financeManager,
    RoleNames.companyAuthority,
  ];

  String _roleDescription(String roleName) {
    switch (roleName) {
      case RoleNames.normalUser:
        return 'Basic access for daily finance tasks and personal dashboard.';
      case RoleNames.superAdmin:
        return 'Full access to all features and settings.';
      case RoleNames.subAdmin:
        return 'Supports admin operations and user management.';
      case RoleNames.hrManager:
        return 'Manages employees, leaves, and HR tasks.';
      case RoleNames.financeManager:
        return 'Controls transactions, payroll, and financial reports.';
      case RoleNames.companyAuthority:
        return 'Approves key actions and company-level decisions.';
      default:
        return 'Custom role.';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _goToLogin() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final auth = context.read<AuthProvider>();
      final success = await auth.register(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        final selectedRole = _selectedRole!;
        final createdUserId = auth.currentUser?.uid;
        final assignmentKey =
            createdUserId ?? emailController.text.trim().toLowerCase();
        context.read<RbacProvider>().assignRole(assignmentKey, selectedRole);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${emailController.text.trim()} created with role "$selectedRole".',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        await _goToLogin();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Failed to create user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        _goToLogin();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEFF2),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF345D96),
          title: const Text(
            'Create New User Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isCreating ? null : _goToLogin,
              child: const Text(
                'Back to Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Add New User',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF345D96),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: nameController,
                          decoration: _buildInputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter user full name',
                            icon: Icons.person,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter full name';
                            }
                            if (value.trim().length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: emailController,
                          decoration: _buildInputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter user email',
                            icon: Icons.email,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email';
                            }
                            if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: phoneController,
                          decoration: _buildInputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter phone number',
                            icon: Icons.phone,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (value.trim().length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: departmentController,
                          decoration: _buildInputDecoration(
                            labelText: 'Department',
                            hintText: 'Enter department',
                            icon: Icons.business,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter department';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: _buildInputDecoration(
                            labelText: 'User Role',
                            hintText: 'Select user role',
                            icon: Icons.security,
                          ),
                          items: roles
                              .map((role) => DropdownMenuItem<String>(
                                    value: role,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(role),
                                        Text(
                                          _roleDescription(role),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRole = value),
                          validator: (value) =>
                              value == null ? 'Please select a role' : null,
                        ),
                        if (_selectedRole != null) ...[
                          const SizedBox(height: 8),
                          Container(
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
                                    _roleDescription(_selectedRole!),
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
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: _buildInputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter password',
                            icon: Icons.lock,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: _buildInputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Confirm password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _obscureConfirmPassword =
                                    !_obscureConfirmPassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isCreating ? null : _goToLogin,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('Cancel'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isCreating ? null : _createUser,
                                icon: _isCreating
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.person_add_alt_1),
                                label: Text(_isCreating
                                    ? 'Creating...'
                                    : 'Create Account'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5A8DEE),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5A8DEE), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
