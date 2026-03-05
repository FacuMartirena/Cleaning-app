import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/company_model.dart';
import 'package:bo_cleaning/core/models/user_model.dart';

class AuthService extends GetxService {
  final _box = GetStorage('User');

  /// Estado reactivo de sesión. true cuando hay token válido.
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Sembrar el estado desde el storage al iniciar el servicio.
    final t = _box.read<String>(Globals.storageToken) ?? '';
    isLoggedIn.value = t.isNotEmpty;
  }

  String? get token => _box.read<String>(Globals.storageToken);

  String? get userId {
    final data = _box.read<Map<dynamic, dynamic>>(Globals.storageUser);
    if (data == null) return null;
    return data['id']?.toString();
  }

  String? get userRole {
    final data = _box.read<Map<dynamic, dynamic>>(Globals.storageUser);
    return data?['role']?.toString();
  }

  String? get companyId {
    final data = _box.read<Map<dynamic, dynamic>>(Globals.storageUser);
    return data?['companyId']?.toString();
  }

  String? get companyName {
    final data = _box.read<Map<dynamic, dynamic>>(Globals.storageUser);
    final company = data?['company'] as Map<dynamic, dynamic>?;
    return company?['name']?.toString();
  }

  bool get isAdmin => userRole == 'Administrador';

  /// Admin o Administrativo (pueden ver UsersView).
  bool get isStaff =>
      userRole == 'Administrador' || userRole == 'Administrativo';

  void saveToken(String token) {
    _box.write(Globals.storageToken, token);
    isLoggedIn.value = true;
  }

  void saveUser(UserModel user) =>
      _box.write(Globals.storageUser, user.toJson());

  /// Actualiza la empresa del usuario en storage (para Administradores).
  void updateUserCompany(CompanyModel company) {
    final data = _box.read<Map<dynamic, dynamic>>(Globals.storageUser);
    if (data == null) return;
    final updated = Map<dynamic, dynamic>.from(data);
    updated['companyId'] = company.id;
    updated['company'] = company.toJson();
    _box.write(Globals.storageUser, updated);
  }

  void clearToken() {
    _box.remove(Globals.storageToken);
    _box.remove(Globals.storageUser);
    isLoggedIn.value = false;
  }
}
