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

  Future<Response> getOrders({String? userId}) {
    final query = userId != null && userId.isNotEmpty ? '?userId=$userId' : '';
    return get('${Globals.ordersPath}$query');
  }

  Future<Response> getOrderById(String orderId) =>
      get('${Globals.ordersPath}/$orderId');

  Future<Response> finalizeOrder(String id) =>
      patch('${Globals.ordersPath}/$id/finalize', {});

  Future<Response> rejectOrder(String id, {String? reason}) => patch(
        '${Globals.ordersPath}/$id/reject',
        reason != null && reason.isNotEmpty ? {'reason': reason} : {},
      );
}
