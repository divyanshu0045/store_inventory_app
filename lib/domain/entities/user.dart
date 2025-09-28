enum UserRole { admin, staff, viewer }

class User {
  final String id;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.role,
  });
}