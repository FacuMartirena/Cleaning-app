class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      };
}
