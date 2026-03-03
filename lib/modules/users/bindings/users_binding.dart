import 'package:get/get.dart';

import 'package:bo_cleaning/modules/companies/services/companies_provider.dart';
import 'package:bo_cleaning/modules/users/controller/users_controller.dart';
import 'package:bo_cleaning/modules/users/services/users_provider.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompaniesProvider>(() => CompaniesProvider());
    Get.lazyPut<UsersProvider>(() => UsersProvider());
    Get.lazyPut<UsersController>(() => UsersController());
  }
}
