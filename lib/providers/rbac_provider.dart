import 'package:flutter/foundation.dart';
import '../models/role_model.dart';

class RbacProvider extends ChangeNotifier {
  final List<Role> _roles = [
    Role(name: RoleNames.superAdmin),
    Role(name: RoleNames.subAdmin),
    Role(name: RoleNames.hrManager),
    Role(name: RoleNames.financeManager),
    Role(name: RoleNames.companyAuthority),
  ];

  final List<RoleAssignment> _assignments = [];

  String? _currentUserId = 'user_admin';

  RbacProvider() {
    // seed demo assignments so demo users have roles
    _seedDemoUsers();
  }

  void _seedDemoUsers() {
    if (_assignments.isNotEmpty) return;
    _assignments.add(RoleAssignment(userId: 'user_admin', roleName: RoleNames.subAdmin));
    _assignments.add(RoleAssignment(userId: 'user_hr', roleName: RoleNames.hrManager));
    _assignments.add(RoleAssignment(userId: 'user_finance', roleName: RoleNames.financeManager));
    _assignments.add(RoleAssignment(userId: 'user_company', roleName: RoleNames.companyAuthority));
  }

  List<Role> get roles => List.unmodifiable(_roles);
  List<RoleAssignment> get assignments => List.unmodifiable(_assignments);
  String? get currentUserId => _currentUserId;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void createCustomRole(String name, {List<Permission>? permissions}) {
    if (_roles.any((r) => r.name == name)) return;
    _roles.add(Role(name: name, permissions: permissions));
    notifyListeners();
  }

  void assignRole(String userId, String roleName) {
    final existing = _assignments.where((a) => a.userId == userId);
    if (existing.isNotEmpty) {
      existing.first.roleName = roleName;
    } else {
      _assignments.add(RoleAssignment(userId: userId, roleName: roleName));
    }
    notifyListeners();
  }

  void revokeRole(String userId) {
    _assignments.removeWhere((a) => a.userId == userId);
    notifyListeners();
  }

  bool userHasRole(String userId, String roleName) {
    return _assignments
        .any((a) => a.userId == userId && a.roleName == roleName);
  }

  void addPermissionToRole(String roleName, Permission perm) {
    final r = _roles.firstWhere((r) => r.name == roleName,
        orElse: () => Role(name: roleName));
    if (!r.permissions.any((p) => p.key == perm.key)) {
      r.permissions.add(perm);
      notifyListeners();
    }
  }

  void assignCustomPermissionToUser(String userId, Permission perm) {
    final a = _assignments.firstWhere((x) => x.userId == userId,
        orElse: () => RoleAssignment(userId: userId, roleName: ''));
    if (!_assignments.contains(a)) _assignments.add(a);
    if (!a.customPermissions.any((p) => p.key == perm.key)) {
      a.customPermissions.add(perm);
      notifyListeners();
    }
  }

  bool userHasPermission(String userId, String permissionKey) {
    final a = _assignments.firstWhere((x) => x.userId == userId,
        orElse: () => RoleAssignment(userId: userId, roleName: ''));
    if (a.roleName.isNotEmpty) {
      final role = _roles.firstWhere((r) => r.name == a.roleName,
          orElse: () => Role(name: ''));
      if (role.permissions.any((p) => p.key == permissionKey)) return true;
    }
    if (a.customPermissions.any((p) => p.key == permissionKey)) return true;
    return false;
  }
}
