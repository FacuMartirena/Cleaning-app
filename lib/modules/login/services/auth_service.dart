import 'package:bo_cleaning/core/models/user_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:bo_cleaning/core/constants/globals.dart';

class AuthService extends GetxService {
  final _box = GetStorage('User');

  bool get isLoggedIn {
    final token = _box.read<String>(Globals.storageToken) ?? '';
    return token.isNotEmpty;
  }

  void saveToken(String token) => _box.write(Globals.storageToken, token);
  void saveUser(UserModel user) =>
      _box.write(Globals.storageUser, user.toJson());
  void clearToken() {
    _box.remove(Globals.storageToken);
    _box.remove(Globals.storageUser);
  }
}
