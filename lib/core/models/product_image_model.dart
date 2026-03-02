import 'package:bo_cleaning/core/constants/globals.dart';

class ProductImageModel {
  final String id;
  final String url;

  const ProductImageModel({required this.id, required this.url});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    final raw = json['url']?.toString() ?? '';
    final resolvedUrl =
        raw.startsWith('/') ? '${Globals.serverBaseUrl}$raw' : raw;
    return ProductImageModel(
      id: json['id']?.toString() ?? '',
      url: resolvedUrl,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}
