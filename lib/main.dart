import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/orders/controllers/orders_controller.dart';
import 'package:bo_cleaning/modules/orders/services/orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:bo_cleaning/config/router/app_pages.dart';
import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/constants/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('User');
  await Get.putAsync<AuthService>(() async => AuthService());
  Get.put<OrdersProvider>(OrdersProvider(), permanent: true);
  Get.put<OrdersController>(OrdersController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(surface: Globals.white),
        scaffoldBackgroundColor: Globals.white,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
