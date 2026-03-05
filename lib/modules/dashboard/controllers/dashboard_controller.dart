import 'package:get/get.dart';

import 'package:bo_cleaning/core/models/order_model.dart';
import 'package:bo_cleaning/core/models/product_model.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/orders/services/orders_provider.dart';
import 'package:bo_cleaning/modules/products/services/products_provider.dart';

class DashboardController extends GetxController {
  DashboardController({
    required AuthService auth,
    required OrdersProvider ordersProvider,
    required ProductsProvider productsProvider,
  }) : _auth = auth,
       _ordersProvider = ordersProvider,
       _productsProvider = productsProvider;

  final AuthService _auth;
  final OrdersProvider _ordersProvider;
  final ProductsProvider _productsProvider;

  final isLoading = true.obs;
  final error = ''.obs;

  final pendingCount = 0.obs;
  final acceptedCount = 0.obs;
  final rejectedCount = 0.obs;
  final lowStockProducts = <ProductModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    loadDashboard();
  }

  bool get isStaff => _auth.isStaff;

  Future<void> loadDashboard() async {
    isLoading.value = true;
    error.value = '';
    pendingCount.value = 0;
    acceptedCount.value = 0;
    rejectedCount.value = 0;
    lowStockProducts.clear();

    final userId = _auth.userId;
    if (userId == null || userId.isEmpty) {
      error.value =
          'No se pudo identificar al usuario. Vuelve a iniciar sesión.';
      isLoading.value = false;
      return;
    }

    try {
      final response = await _ordersProvider.getOrders(userId: userId);
      if (response.statusCode == 200) {
        final body = response.body;
        List<dynamic> data;
        if (body is List) {
          data = body;
        } else if (body is Map && body['data'] is List) {
          data = body['data'] as List;
        } else {
          data = [];
        }
        final orders = data
            .map(
              (e) =>
                  OrderHistoryModel.fromJsonOrLegacy(e as Map<String, dynamic>),
            )
            .toList();

        int pending = 0, accepted = 0, rejected = 0;
        for (final order in orders) {
          switch (order.statusCode) {
            case 0:
              pending++;
              break;
            case 1:
              accepted++;
              break;
            case 2:
              rejected++;
              break;
          }
        }
        pendingCount.value = pending;
        acceptedCount.value = accepted;
        rejectedCount.value = rejected;
      } else {
        error.value =
            response.body?['message']?.toString() ??
            'Error al cargar el dashboard';
        return;
      }

      if (_auth.isStaff) {
        final productsResponse = await _productsProvider.getProducts(
          limit: 200,
          offset: 0,
        );
        if (productsResponse.statusCode == 200) {
          final body = productsResponse.body;
          final list = body is List
              ? body
              : body is Map && body['data'] is List
                  ? body['data'] as List
                  : <dynamic>[];
          final lowStock = list
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .where((p) => p.quantityAvailable < 10 && p.active)
              .toList();
          lowStockProducts.value = lowStock;
        }
      }
    } catch (_) {
      error.value = 'No se pudo conectar con el servidor';
    } finally {
      isLoading.value = false;
    }
  }
}
