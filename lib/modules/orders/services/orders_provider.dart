import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';

class OrdersProvider extends GetConnect {
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

  Future<Response> createOrder(Map<String, dynamic> body) =>
      post(Globals.ordersPath, body);
}
