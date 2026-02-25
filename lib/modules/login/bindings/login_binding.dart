import 'package:get/get.dart';

import 'package:bo_cleaning/modules/login/controllers/login_controller.dart';
import 'package:bo_cleaning/modules/login/services/auth_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
