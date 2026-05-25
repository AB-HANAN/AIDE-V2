enum AppRole { admin, user }

extension AppRoleX on AppRole {
  String get label => this == AppRole.admin ? 'Admin' : 'User';
}
