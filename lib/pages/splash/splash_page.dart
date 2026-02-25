import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_route.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Get.offAllNamed(AppRoutes.init);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/globalLogoInit.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
