import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/modules/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Globals.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/globalLogoInit.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
