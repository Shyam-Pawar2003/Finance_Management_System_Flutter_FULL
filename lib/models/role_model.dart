class RoleNames {
  static const String superAdmin = 'Super Admin';
  static const String subAdmin = 'Sub-admin';
  static const String hrManager = 'HR Manager';
  static const String financeManager = 'Finance Manager';
  static const String companyAuthority = 'Company Authority';
}

class Permission {
  final String key;
  final String description;

  Permission({required this.key, required this.description});
}

class Role {
  final String name;
  final List<Permission> permissions;

  Role({required this.name, List<Permission>? permissions})
      : permissions = permissions ?? [];
}

class RoleAssignment {
  final String userId;
  String roleName;
  List<Permission> customPermissions;

  RoleAssignment(
      {required this.userId,
      required this.roleName,
      List<Permission>? customPermissions})
      : customPermissions = customPermissions ?? [];
}
