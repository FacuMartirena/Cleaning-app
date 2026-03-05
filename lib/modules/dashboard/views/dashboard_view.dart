import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/widgets/app_drawer.dart';
import 'package:bo_cleaning/modules/dashboard/controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Globals.primary,
        foregroundColor: Globals.white,
      ),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Globals.primary),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 56, color: Globals.hint),
                  const SizedBox(height: 16),
                  Text(
                    controller.error.value,
                    style: const TextStyle(color: Globals.hint),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: controller.loadDashboard,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: FilledButton.styleFrom(backgroundColor: Globals.primary),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: Globals.primary,
          onRefresh: controller.loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Mis órdenes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Globals.hint,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _OrderStatCard(
                        label: 'Pendientes',
                        count: controller.pendingCount.value,
                        color: Globals.pending,
                        onTap: () => Get.toNamed(AppRoutes.orders),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OrderStatCard(
                        label: 'Aceptadas',
                        count: controller.acceptedCount.value,
                        color: Globals.success,
                        onTap: () => Get.toNamed(AppRoutes.orders),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _OrderStatCard(
                        label: 'Rechazadas',
                        count: controller.rejectedCount.value,
                        color: Globals.error,
                        onTap: () => Get.toNamed(AppRoutes.orders),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
                if (controller.isStaff) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Productos con bajo stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Globals.hint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menos de 10 unidades disponibles',
                    style: TextStyle(
                      fontSize: 12,
                      color: Globals.hint.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final list = controller.lowStockProducts;
                    if (list.isEmpty) {
                      return Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Globals.success, size: 28),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Todo el stock en orden',
                                  style: TextStyle(color: Globals.hint),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: list
                          .map(
                            (p) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Globals.primary.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.inventory_2,
                                    color: Globals.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '${p.unitOfMeasure} · ${p.quantityAvailable} disponibles',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Globals.hint,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Globals.hint,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.products),
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Ir a Productos'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Globals.primary,
                        side: const BorderSide(color: Globals.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _OrderStatCard extends StatelessWidget {
  const _OrderStatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Órdenes $label',
                style: const TextStyle(
                  fontSize: 12,
                  color: Globals.hint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
