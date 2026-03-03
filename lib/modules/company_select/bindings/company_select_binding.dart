import 'package:get/get.dart';

import 'package:bo_cleaning/modules/companies/services/companies_provider.dart';
import 'package:bo_cleaning/modules/company_select/controllers/company_select_controller.dart';

class CompanySelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompaniesProvider>(() => CompaniesProvider(), fenix: true);
    Get.lazyPut<CompanySelectController>(() => CompanySelectController(), fenix: true);
  }
}
