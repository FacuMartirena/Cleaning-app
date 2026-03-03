class CompanyModel {
  final String id;
  final String name;

  const CompanyModel({required this.id, required this.name});

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
