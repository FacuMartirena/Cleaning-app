import 'package:get/get.dart';

import 'package:bo_cleaning/modules/products/controllers/products_controller.dart';
import 'package:bo_cleaning/modules/products/services/products_provider.dart';
import 'package:bo_cleaning/modules/users/services/users_provider.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersProvider>(() => UsersProvider());
    Get.lazyPut<ProductsProvider>(() => ProductsProvider(), fenix: true);
    Get.lazyPut<ProductsController>(() => ProductsController(), fenix: true);
  }
}
