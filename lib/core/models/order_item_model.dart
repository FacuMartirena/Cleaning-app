import 'package:bo_cleaning/core/models/product_model.dart';

class OrderItemModel {
  final ProductModel product;
  int quantity;

  OrderItemModel({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': quantity,
      };
}
