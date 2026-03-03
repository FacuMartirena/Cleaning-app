import 'package:bo_cleaning/core/models/company_model.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String ci;
  final String role;
  final bool active;
  final String? companyId;
  final CompanyModel? company;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.ci,
    required this.role,
    this.active = true,
    this.companyId,
    this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final companyJson = json['company'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      ci: json['ci']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Limpiador',
      active: json['active'] as bool? ?? true,
      companyId: json['companyId']?.toString(),
      company: companyJson != null ? CompanyModel.fromJson(companyJson) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'ci': ci,
        'role': role,
        'active': active,
        if (companyId != null) 'companyId': companyId,
        if (company != null) 'company': company!.toJson(),
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
    String? companyId,
  }) =>
      {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'ci': ci,
        'role': role,
        'active': active,
        if (companyId != null && companyId.isNotEmpty) 'companyId': companyId,
      };
}
