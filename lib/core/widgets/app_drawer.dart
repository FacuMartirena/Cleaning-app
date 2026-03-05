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
    final auth = Get.find<AuthService>();
    final companyName = auth.companyName;
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
              top: MediaQuery.of(context).padding.top + 12,
            ),
            decoration: const BoxDecoration(color: Globals.primary),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: const Text(
                    'Menú',
                    style: TextStyle(
                      color: Globals.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (companyName != null && companyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    companyName,
                    style: TextStyle(
                      color: Globals.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          _DrawerMenuTile(
            icon: Icons.dashboard_outlined,
            label: 'Inicio',
            semanticsLabel: 'Ir al inicio',
            onTap: () {
              Get.back();
              Get.offAllNamed(AppRoutes.dashboard);
            },
          ),
          _DrawerMenuTile(
            icon: Icons.inventory_2_outlined,
            label: 'Productos',
            semanticsLabel: 'Ver catálogo de productos',
            onTap: () {
              Get.back();
              Get.offAllNamed(AppRoutes.products);
            },
          ),
          _DrawerMenuTile(
            icon: Icons.shopping_cart_outlined,
            label: 'Mi pedido',
            semanticsLabel: 'Ver mi pedido actual',
            onTap: () {
              if (Get.isRegistered<OrdersController>()) {
                Get.find<OrdersController>().goToCartTab();
              }
              Get.back();
              Get.toNamed(AppRoutes.orders);
            },
          ),
          if (auth.isStaff)
            _DrawerMenuTile(
              icon: Icons.people_outline,
              label: 'Usuarios',
              semanticsLabel: 'Gestionar usuarios',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.users);
              },
            ),
          const Spacer(),
          const Divider(height: 1),
          _DrawerMenuTile(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            semanticsLabel: 'Cerrar sesión y salir',
            onTap: () => Get.offAllNamed(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}

/// ítem reutilizable del menú con icono, etiqueta y semántica para accesibilidad.
class _DrawerMenuTile extends StatelessWidget {
  const _DrawerMenuTile({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ListTile(
        leading: Icon(icon, color: Globals.primary),
        title: Text(label),
        onTap: onTap,
        minLeadingWidth: 40,
      ),
    );
  }
}
