import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/modules/login/services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _auth;
  SplashController({required AuthService auth}) : _auth = auth;

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 3), () {
      _goToLoginOrProducts();
    });
  }

  void _goToLoginOrProducts() {
    if (_auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.products);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
