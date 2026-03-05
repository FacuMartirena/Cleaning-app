import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/user_model.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/login/services/auth_provider.dart';

class LoginController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthService _authService;
  final AuthProvider _authProvider;

  LoginController({
    required AuthService authService,
    required AuthProvider authProvider,
  })  : _authService = authService,
        _authProvider = authProvider;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePassword = true.obs;
  final isLoading = false.obs;

  // ── Staggered entry animations ────────────────────────────────────────────────
  late AnimationController animController;
  late Animation<double> emailAnim;
  late Animation<double> passwordAnim;
  late Animation<double> buttonAnim;

  @override
  void onInit() {
    super.onInit();
    animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    emailAnim = CurvedAnimation(
      parent: animController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    passwordAnim = CurvedAnimation(
      parent: animController,
      curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
    );
    buttonAnim = CurvedAnimation(
      parent: animController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    animController.forward();
  }

  @override
  void onClose() {
    animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscure() => obscurePassword.toggle();

  // ── Login ─────────────────────────────────────────────────────────────────────

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Campos requeridos',
        'Ingresa tu email y contraseña.',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authProvider.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body['token'] as String;
        final user = UserModel.fromJson(
          response.body['user'] as Map<String, dynamic>,
        );
        _authService.saveToken(token);
        _authService.saveUser(user);
        if (_authService.isAdmin && user.companyId == null) {
          Get.offAllNamed(AppRoutes.companySelect);
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        final message =
            response.body?['message'] ?? 'Credenciales incorrectas.';
        Get.snackbar(
          'Error al iniciar sesión',
          message.toString(),
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error de conexión',
        'No se pudo conectar con el servidor.',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
