import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/modules/company_select/bindings/company_select_binding.dart';
import 'package:bo_cleaning/modules/company_select/views/company_select_view.dart';
import 'package:bo_cleaning/modules/login/bindings/login_binding.dart';
import 'package:bo_cleaning/modules/login/views/login_view.dart';
import 'package:bo_cleaning/modules/orders/bindings/orders_binding.dart';
import 'package:bo_cleaning/modules/orders/views/orders_view.dart';
import 'package:bo_cleaning/modules/products/bindings/products_binding.dart';
import 'package:bo_cleaning/modules/products/views/products_view.dart';
import 'package:bo_cleaning/modules/splash/bindings/splash_binding.dart';
import 'package:bo_cleaning/modules/splash/views/splash_view.dart';
import 'package:bo_cleaning/modules/users/bindings/users_binding.dart';
import 'package:bo_cleaning/modules/users/views/users_view.dart';

abstract class AppPages {
  static final List<GetPage<void>> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.companySelect,
      page: () => const CompanySelectView(),
      binding: CompanySelectBinding(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UsersView(),
      binding: UsersBinding(),
    ),
  ];
}
