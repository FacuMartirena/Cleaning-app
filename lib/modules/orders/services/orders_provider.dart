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

  /// GET /orders con filtro por rol:
  /// - Si se envía [userId]: el backend debe filtrar por ese usuario (ej. limpiador ve solo sus pedidos).
  /// - Si se envía [companyId]: el backend debe filtrar por esa compañía (ej. administrador ve pedidos de la empresa).
  Future<Response> getOrders({String? userId, String? companyId}) {
    final params = <String, dynamic>{};
    if (userId != null && userId.isNotEmpty) params['userId'] = userId;
    if (companyId != null && companyId.isNotEmpty) {
      params['companyId'] = companyId;
    }
    return get(Globals.ordersPath, query: params.isEmpty ? null : params);
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
