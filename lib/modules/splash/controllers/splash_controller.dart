import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';

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
    if (!_auth.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    if (_auth.isAdmin && _auth.companyId == null) {
      Get.offAllNamed(AppRoutes.companySelect);
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }
}
