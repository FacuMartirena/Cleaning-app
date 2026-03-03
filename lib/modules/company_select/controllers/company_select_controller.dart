import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/models/company_model.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/companies/services/companies_provider.dart';

class CompanySelectController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final CompaniesProvider _provider = Get.find<CompaniesProvider>();

  final companies = <CompanyModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = Rx<String?>(null);

  @override
  void onReady() {
    super.onReady();
    loadCompanies();
  }

  Future<void> loadCompanies() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _provider.getCompanies();
      if (res.isOk && res.body != null) {
        final list = res.body as List<dynamic>? ?? [];
        companies.value = list
            .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        errorMessage.value =
            res.body?['message']?.toString() ?? 'Error al cargar empresas';
      }
    } catch (_) {
      errorMessage.value = 'No se pudo conectar con el servidor';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCompany(CompanyModel company) {
    _auth.updateUserCompany(company);
    Get.offAllNamed(AppRoutes.products);
  }

  void logout() {
    _auth.clearToken();
    Get.offAllNamed(AppRoutes.login);
  }
}
