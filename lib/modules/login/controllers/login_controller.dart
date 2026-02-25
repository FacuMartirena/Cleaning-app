import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:bo_cleaning/config/router/app_route.dart';
import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/user_model.dart';
import 'package:bo_cleaning/modules/login/services/auth_service.dart';

class LoginController extends GetxController {
  final _authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePassword = true.obs;
  final isLoading = false.obs;

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Campos requeridos',
        'Ingresa tu email y contraseña.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _authService.loginRequest(
        email: email,
        password: password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body['token'] as String;
        final user = UserModel.fromJson(
          response.body['user'] as Map<String, dynamic>,
        );

        final box = GetStorage('User');
        box.write(Globals.storageToken, token);
        box.write(Globals.storageUser, user.toJson());

        Get.offAllNamed(AppRoutes.products);
      } else {
        final message = response.body?['message'] ?? 'Credenciales incorrectas.';
        Get.snackbar(
          'Error al iniciar sesión',
          message.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error de conexión',
        'No se pudo conectar con el servidor.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
