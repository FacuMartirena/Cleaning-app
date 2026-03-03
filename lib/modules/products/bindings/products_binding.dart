import 'package:get/get.dart';

import 'package:bo_cleaning/modules/products/controllers/products_controller.dart';
import 'package:bo_cleaning/modules/products/services/products_provider.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsProvider>(() => ProductsProvider(), fenix: true);
    Get.lazyPut<ProductsController>(() => ProductsController(), fenix: true);
  }
}
