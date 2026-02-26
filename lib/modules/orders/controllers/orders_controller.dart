import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/order_item_model.dart';
import 'package:bo_cleaning/core/models/product_model.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/orders/services/orders_provider.dart';

class OrdersController extends GetxController {
  final OrdersProvider _provider = Get.find<OrdersProvider>();
  final AuthService _auth = Get.find<AuthService>();

  final items = <String, OrderItemModel>{}.obs;
  final isSubmitting = false.obs;

  int get totalItems =>
      items.values.fold(0, (sum, item) => sum + item.quantity);

  bool hasProduct(String productId) => items.containsKey(productId);

  int quantityOf(String productId) => items[productId]?.quantity ?? 0;

  void addProduct(ProductModel product) {
    if (items.containsKey(product.id)) {
      items[product.id]!.quantity++;
      items.refresh();
    } else {
      items[product.id] = OrderItemModel(product: product, quantity: 1);
    }
  }

  void removeOne(String productId) {
    if (!items.containsKey(productId)) return;
    if (items[productId]!.quantity <= 1) {
      items.remove(productId);
    } else {
      items[productId]!.quantity--;
      items.refresh();
    }
  }

  void removeProduct(String productId) => items.remove(productId);

  void clearCart() => items.clear();

  Future<void> confirmOrder() async {
    if (items.isEmpty) return;

    final userId = _auth.userId;
    if (userId == null || userId.isEmpty) {
      Get.snackbar(
        'Error',
        'No se pudo identificar al usuario. Vuelve a iniciar sesión.',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final body = {
        'userId': userId,
        'items': items.values.map((e) => e.toJson()).toList(),
      };

      final response = await _provider.createOrder(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearCart();
        Get.back();
        Get.snackbar(
          'Pedido enviado',
          'Tu pedido fue creado exitosamente',
          backgroundColor: Globals.success,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        final message = response.body?['message']?.toString() ??
            'Error al crear el pedido';
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo conectar con el servidor',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
