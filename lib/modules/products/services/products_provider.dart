import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';

class ProductsProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = Globals.apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 15);
    httpClient.addRequestModifier<dynamic>((request) {
      final token = Get.find<AuthService>().token;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = Globals.authorizationBearer(token);
      }
      return request;
    });
    super.onInit();
  }

  Future<Response> getProducts({int limit = 10, int offset = 0}) =>
      get(Globals.productsPath,
          query: {'limit': limit.toString(), 'offset': offset.toString()});

  Future<Response> createProduct(FormData formData) =>
      post(Globals.productsPath, formData);
}
