import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/orders/controllers/orders_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final companyName = Get.find<AuthService>().companyName;
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(color: Globals.primary),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menú',
                  style: TextStyle(
                    color: Globals.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (companyName != null && companyName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    companyName,
                    style: TextStyle(
                      color: Globals.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Productos'),
            onTap: () => Get.offAllNamed(AppRoutes.products),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Mi pedido'),
            onTap: () {
              if (Get.isRegistered<OrdersController>()) {
                Get.find<OrdersController>().goToCartTab();
              }
              Get.back();
              Get.toNamed(AppRoutes.orders);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Usuarios'),
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.users);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () => Get.offAllNamed(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}
