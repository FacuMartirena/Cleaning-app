import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/constants/globals.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(color: Globals.primary),
            alignment: Alignment.bottomLeft,
            child: const Text(
              'Menú',
              style: TextStyle(
                color: Globals.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
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
