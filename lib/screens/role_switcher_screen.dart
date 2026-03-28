import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rbac_provider.dart';
import '../models/role_model.dart';

class RoleSwitcherScreen extends StatefulWidget {
  const RoleSwitcherScreen({super.key});

  @override
  State<RoleSwitcherScreen> createState() => _RoleSwitcherScreenState();
}

class _RoleSwitcherScreenState extends State<RoleSwitcherScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _customRoleController = TextEditingController();
  final TextEditingController _permKeyController = TextEditingController();
  final TextEditingController _permDescController = TextEditingController();

  String? _selectedAssignRole;
  String? _selectedPermissionRole;

  @override
  void dispose() {
    _userController.dispose();
    _customRoleController.dispose();
    _permKeyController.dispose();
    _permDescController.dispose();
    super.dispose();
  }

  String _roleDescription(String roleName) {
    switch (roleName) {
      case RoleNames.normalUser:
        return 'Basic access for regular users and personal finance actions.';
      case RoleNames.superAdmin:
        return 'Full control over users, permissions, and settings.';
      case RoleNames.subAdmin:
        return 'Manages day-to-day operations and team access.';
      case RoleNames.hrManager:
        return 'Handles employees, attendance, and HR workflows.';
      case RoleNames.financeManager:
        return 'Manages budgets, payroll, and transactions.';
      case RoleNames.companyAuthority:
        return 'Approves high-level company actions and decisions.';
      default:
        return 'Custom role with configurable permissions.';
    }
  }

  void _showMessage(String message, {Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rbac = Provider.of<RbacProvider>(context);
    final roleNames = rbac.roles.map((r) => r.name).toList();
    final assignRole = roleNames.contains(_selectedAssignRole)
        ? _selectedAssignRole
        : (roleNames.isNotEmpty ? roleNames.first : null);
    final permissionRole = roleNames.contains(_selectedPermissionRole)
        ? _selectedPermissionRole
        : (roleNames.isNotEmpty ? roleNames.first : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Role Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Role Catalog',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a role with confidence using clear descriptions below.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              ...rbac.roles.map(
                (role) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: Text(role.name),
                    subtitle: Text(_roleDescription(role.name)),
                    trailing: role.permissions.isEmpty
                        ? const Text(
                            'No permissions',
                            style: TextStyle(color: Colors.black45),
                          )
                        : Text('${role.permissions.length} permissions'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Assign Role to User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'User ID or email',
                  hintText: 'e.g. user@company.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: assignRole,
                items: rbac.roles
                    .map((r) =>
                        DropdownMenuItem(value: r.name, child: Text(r.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAssignRole = v),
                decoration: const InputDecoration(
                  labelText: 'Select role',
                  border: OutlineInputBorder(),
                ),
              ),
              if (assignRole != null) ...[
                const SizedBox(height: 8),
                Text(
                  _roleDescription(assignRole),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final uid = _userController.text.trim();
                      if (uid.isEmpty) {
                        _showMessage('Please enter user ID or email',
                            bgColor: Colors.red);
                        return;
                      }
                      final role = assignRole;
                      if (role == null) {
                        _showMessage('No roles available to assign',
                            bgColor: Colors.red);
                        return;
                      }
                      rbac.assignRole(uid, role);
                      _showMessage('Assigned "$role" to $uid',
                          bgColor: Colors.green);
                    },
                    child: const Text('Assign Role'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final uid = _userController.text.trim();
                      if (uid.isEmpty) {
                        _showMessage('Please enter user ID or email',
                            bgColor: Colors.red);
                        return;
                      }
                      rbac.revokeRole(uid);
                      _showMessage('Revoked role for $uid',
                          bgColor: Colors.red);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: const Text('Revoke'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Custom Role',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customRoleController,
                decoration: const InputDecoration(
                  labelText: 'Role name',
                  hintText: 'e.g. Payroll Reviewer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final name = _customRoleController.text.trim();
                  if (name.isEmpty) {
                    _showMessage('Please enter a role name',
                        bgColor: Colors.red);
                    return;
                  }
                  final exists = rbac.roles
                      .any((r) => r.name.toLowerCase() == name.toLowerCase());
                  if (exists) {
                    _showMessage('Role "$name" already exists',
                        bgColor: Colors.orange);
                    return;
                  }
                  rbac.createCustomRole(name);
                  _customRoleController.clear();
                  _showMessage('Custom role "$name" created',
                      bgColor: Colors.green);
                },
                child: const Text('Create Role'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Custom Permissions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: permissionRole,
                items: rbac.roles
                    .map((r) =>
                        DropdownMenuItem(value: r.name, child: Text(r.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPermissionRole = v),
                decoration: const InputDecoration(
                  labelText: 'Role for permission',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _permKeyController,
                decoration: const InputDecoration(
                  labelText: 'Permission key',
                  hintText: 'e.g. approve_payroll',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _permDescController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Short explanation for this permission',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final role = permissionRole;
                  if (role == null) {
                    _showMessage('Please choose a role first',
                        bgColor: Colors.red);
                    return;
                  }
                  final key = _permKeyController.text.trim();
                  final desc = _permDescController.text.trim();
                  if (key.isEmpty) {
                    _showMessage('Permission key is required',
                        bgColor: Colors.red);
                    return;
                  }
                  final perm = Permission(key: key, description: desc);
                  rbac.addPermissionToRole(role, perm);
                  _permKeyController.clear();
                  _permDescController.clear();
                  _showMessage('Permission "$key" added to "$role"',
                      bgColor: Colors.green);
                },
                child: const Text('Add Permission'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Current Assignments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (rbac.assignments.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No role assignments yet.'),
                  ),
                ),
              ...rbac.assignments.map((a) => ListTile(
                    title: Text(a.userId),
                    subtitle: Text('Role: ${a.roleName}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.redAccent),
                      onPressed: () {
                        rbac.revokeRole(a.userId);
                        _showMessage('Revoked role for ${a.userId}',
                            bgColor: Colors.red);
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
