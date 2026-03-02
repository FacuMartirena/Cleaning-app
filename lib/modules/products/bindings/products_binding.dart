import 'package:get/get.dart';

import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/orders/controllers/orders_controller.dart';
import 'package:bo_cleaning/modules/orders/services/orders_provider.dart';
import 'package:bo_cleaning/modules/products/controllers/products_controller.dart';
import 'package:bo_cleaning/modules/products/services/products_provider.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<ProductsProvider>(() => ProductsProvider());
    if (!Get.isRegistered<ProductsController>()) {
      Get.put<ProductsController>(ProductsController(), permanent: true);
    }
    Get.lazyPut<OrdersProvider>(() => OrdersProvider());
    Get.put<OrdersController>(OrdersController(), permanent: true);
  }
}
