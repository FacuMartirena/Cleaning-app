import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:bo_cleaning/config/router/app_route.dart';
import 'package:bo_cleaning/core/constants/globals.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateUserLogged());
  }

  void _validateUserLogged() {
    final box = GetStorage('User');
    final token = box.read<String>(Globals.storageToken) ?? '';

    if (token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.products);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
