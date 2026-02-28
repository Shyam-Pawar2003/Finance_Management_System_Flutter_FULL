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

  @override
  Widget build(BuildContext context) {
    final rbac = Provider.of<RbacProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Role Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Predefined Roles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    rbac.roles.map((r) => Chip(label: Text(r.name))).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Assign Role to User',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                  controller: _userController,
                  decoration:
                      const InputDecoration(labelText: 'User ID / email')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: rbac.roles.isNotEmpty ? rbac.roles.first.name : null,
                items: rbac.roles
                    .map((r) =>
                        DropdownMenuItem(value: r.name, child: Text(r.name)))
                    .toList(),
                onChanged: (v) {},
                onSaved: (v) {},
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final uid = _userController.text.trim();
                      if (uid.isEmpty) return;
                      final role = rbac.roles.first.name;
                      rbac.assignRole(uid, role);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assigned role')));
                    },
                    child: const Text('Assign (quick) to current role'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final uid = _userController.text.trim();
                      if (uid.isEmpty) return;
                      rbac.revokeRole(uid);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Revoked role')));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: const Text('Revoke'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Create Custom Role',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                  controller: _customRoleController,
                  decoration: const InputDecoration(labelText: 'Role name')),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final name = _customRoleController.text.trim();
                  if (name.isEmpty) return;
                  rbac.createCustomRole(name);
                  _customRoleController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Custom role created')));
                },
                child: const Text('Create Role'),
              ),
              const SizedBox(height: 24),
              const Text('Custom Permissions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                  controller: _permKeyController,
                  decoration:
                      const InputDecoration(labelText: 'Permission key')),
              const SizedBox(height: 8),
              TextField(
                  controller: _permDescController,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final key = _permKeyController.text.trim();
                  final desc = _permDescController.text.trim();
                  if (key.isEmpty) return;
                  final perm = Permission(key: key, description: desc);
                  // attach to first role for demo
                  if (rbac.roles.isNotEmpty)
                    rbac.addPermissionToRole(rbac.roles.first.name, perm);
                  _permKeyController.clear();
                  _permDescController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Permission added to role')));
                },
                child: const Text('Add Permission (to first role)'),
              ),
              const SizedBox(height: 24),
              const Text('Assignments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...rbac.assignments.map((a) => ListTile(
                    title: Text(a.userId),
                    subtitle: Text('Role: ${a.roleName}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.redAccent),
                      onPressed: () => rbac.revokeRole(a.userId),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
