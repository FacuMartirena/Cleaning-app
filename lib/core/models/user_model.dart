class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String ci;
  final String role;
  final bool active;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.ci,
    required this.role,
    this.active = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        ci: json['ci']?.toString() ?? '',
        role: json['role']?.toString() ?? 'Usuario',
        active: json['active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'ci': ci,
        'role': role,
        'active': active,
      };

  /// Body para crear usuario (POST /api/users).
  static Map<String, dynamic> createBody({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String ci,
    required String role,
    bool active = true,
  }) =>
      {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'ci': ci,
        'role': role,
        'active': active,
      };
}
