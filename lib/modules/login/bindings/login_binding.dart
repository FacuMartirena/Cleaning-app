import 'package:get/get.dart';

import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/login/controllers/login_controller.dart';
import 'package:bo_cleaning/modules/login/services/auth_provider.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<LoginController>(
      () => LoginController(
        authService: Get.find<AuthService>(),
        authProvider: Get.find<AuthProvider>(),
      ),
    );
  }
}
