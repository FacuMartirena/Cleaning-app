import 'package:get/get.dart';

import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController(auth: Get.find<AuthService>()));
  }
}
