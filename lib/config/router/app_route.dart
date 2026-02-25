import 'package:get/get.dart';

import 'package:bo_cleaning/modules/login/bindings/login_binding.dart';
import 'package:bo_cleaning/modules/login/views/login_view.dart';
import 'package:bo_cleaning/pages/init/init_page.dart';
import 'package:bo_cleaning/pages/splash/splash_page.dart';
import 'package:bo_cleaning/screens/products/products_screen.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const init = '/';
  static const login = '/login';
  static const products = '/products';

  static final pages = [
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: init, page: () => const InitPage()),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(name: products, page: () => const ProductsScreen()),
  ];
}
