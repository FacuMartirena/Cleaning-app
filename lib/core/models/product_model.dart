import 'package:bo_cleaning/core/models/product_image_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String unitOfMeasure;
  final num quantityAvailable;
  final String? description;
  final bool active;
  final String lastUpdated;
  final List<ProductImageModel> images;
  final String? assetImagePath;

  const ProductModel({
    required this.id,
    required this.name,
    required this.unitOfMeasure,
    required this.quantityAvailable,
    this.description,
    required this.active,
    required this.lastUpdated,
    this.images = const [],
    this.assetImagePath,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List<dynamic>?;
    final assetRaw = json['assetImage']?.toString();
    final assetPath = assetRaw != null && assetRaw.isNotEmpty
        ? (assetRaw.startsWith('assets/')
              ? assetRaw
              : 'assets/images/$assetRaw')
        : null;
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unitOfMeasure: json['unitOfMeasure']?.toString() ?? '',
      quantityAvailable: (json['quantityAvailable'] as num?) ?? 0,
      description: json['description']?.toString(),
      active: json['active'] as bool? ?? true,
      lastUpdated: json['lastUpdated']?.toString() ?? '',
      images:
          imagesList
              ?.map(
                (e) => ProductImageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      assetImagePath: assetPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unitOfMeasure': unitOfMeasure,
    'quantityAvailable': quantityAvailable,
    'description': description,
    'active': active,
    'lastUpdated': lastUpdated,
    'images': images.map((e) => e.toJson()).toList(),
    if (assetImagePath != null) 'assetImage': assetImagePath,
  };
}
