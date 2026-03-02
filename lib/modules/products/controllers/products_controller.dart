import 'package:get/get.dart';

import 'package:bo_cleaning/core/models/product_model.dart';
import 'package:bo_cleaning/modules/products/services/products_provider.dart';

class ProductsController extends GetxController {
  final ProductsProvider _provider = Get.find<ProductsProvider>();

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  final productAssetMap = <String, String>{
    'Detergent': 'assets/images/products/detergente.jpg',
  };

  String? getAssetPathForProduct(ProductModel product) =>
      product.assetImagePath ??
      productAssetMap[product.id] ??
      productAssetMap[product.name];

  @override
  void onReady() {
    super.onReady();
    loadProducts();
  }

  Future<void> loadProducts({int limit = 10, int offset = 0}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _provider.getProducts(
        limit: limit,
        offset: offset,
      );

      if (response.statusCode == 200) {
        final list = response.body as List<dynamic>?;
        products.value = list
                ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      } else {
        errorMessage.value =
            response.body?['message']?.toString() ?? 'Error al cargar productos';
      }
    } catch (_) {
      errorMessage.value = 'No se pudo conectar con el servidor';
    } finally {
      isLoading.value = false;
    }
  }
}
