import 'package:bo_cleaning/core/models/product_model.dart';

class OrderItemModel {
  final ProductModel product;
  int quantity;

  OrderItemModel({required this.product, this.quantity = 1});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    final product = productJson != null
        ? ProductModel.fromJson(productJson)
        : ProductModel(
            id: json['productId']?.toString() ?? '',
            name: json['productName']?.toString() ?? 'Producto',
            unitOfMeasure: json['unitOfMeasure']?.toString() ?? '',
            quantityAvailable: 0,
            active: true,
            lastUpdated: '',
          );
    return OrderItemModel(
      product: product,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': quantity,
      };
}
