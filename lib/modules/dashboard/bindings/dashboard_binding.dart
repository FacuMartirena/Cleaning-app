import 'package:get/get.dart';

import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:bo_cleaning/modules/orders/services/orders_provider.dart';
import 'package:bo_cleaning/modules/products/services/products_provider.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersProvider>(() => OrdersProvider());
    Get.lazyPut<ProductsProvider>(() => ProductsProvider());
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        auth: Get.find<AuthService>(),
        ordersProvider: Get.find<OrdersProvider>(),
        productsProvider: Get.find<ProductsProvider>(),
      ),
    );
  }
}
