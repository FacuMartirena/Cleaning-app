import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/modules/login/controllers/login_controller.dart';
import 'package:bo_cleaning/modules/login/widgets/login_input_field.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 24,
                vertical: 40,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logoHorizontal.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Email (stagger 1) ─────────────────────────────────────────
                    _AnimatedSection(
                      animation: controller.emailAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EMAIL',
                            style: TextStyle(
                              color: Globals.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LoginInputField(
                            controller: controller.emailController,
                            hintText: 'email@mail.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Password (stagger 2) ──────────────────────────────────────
                    _AnimatedSection(
                      animation: controller.passwordAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PASSWORD',
                            style: TextStyle(
                              color: Globals.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => LoginInputField(
                              controller: controller.passwordController,
                              hintText: '********',
                              obscureText: controller.obscurePassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Globals.hint,
                                ),
                                onPressed: controller.toggleObscure,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Forgot your password?',
                                  style: TextStyle(
                                    color: Globals.primary,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Container(
                                  height: 1,
                                  width: 145,
                                  color: Globals.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Login button (stagger 3) ──────────────────────────────────
                    _AnimatedSection(
                      animation: controller.buttonAnim,
                      child: Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: Globals.transparent,
                            child: InkWell(
                              onTap: controller.isLoading.value
                                  ? null
                                  : controller.login,
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Globals.gradientStart,
                                      Globals.gradientEnd,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Globals.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Globals.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated section wrapper (explicit animation from controller) ─────────────

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final v = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - v)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
