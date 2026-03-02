import 'package:get/get.dart';

import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/orders/controllers/orders_controller.dart';
import 'package:bo_cleaning/modules/orders/services/orders_provider.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<OrdersProvider>(() => OrdersProvider());
    if (!Get.isRegistered<OrdersController>()) {
      Get.put<OrdersController>(OrdersController(), permanent: true);
    }
  }
}
