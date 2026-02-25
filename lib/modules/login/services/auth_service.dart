import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';

class AuthService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = Globals.apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  Future<Response> loginRequest({
    required String email,
    required String password,
  }) =>
      post(
        Globals.authLogin,
        {'email': email, 'password': password},
      );
}
