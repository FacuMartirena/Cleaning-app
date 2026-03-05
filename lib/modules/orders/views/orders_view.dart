import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/order_item_model.dart';
import 'package:bo_cleaning/core/models/order_model.dart'
    show OrderHistoryItemModel, OrderHistoryModel;
import 'package:bo_cleaning/core/widgets/app_drawer.dart';
import 'package:bo_cleaning/modules/orders/controllers/orders_controller.dart';
import 'package:bo_cleaning/modules/products/controllers/products_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: Globals.primary,
        foregroundColor: Globals.white,
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: Globals.white,
          labelColor: Globals.white,
          unselectedLabelColor: Globals.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(icon: Icon(Icons.shopping_cart_outlined), text: 'Mi pedido'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _CartTab(ctrl: controller),
          _HistoryTab(ctrl: controller),
        ],
      ),
    );
  }
}

// ── TAB 1: Carrito actual ─────────────────────────────────────────────────────

class _CartTab extends StatelessWidget {
  const _CartTab({required this.ctrl});

  final OrdersController ctrl;

  @override
  Widget build(BuildContext context) {
    final productsCtrl = Get.find<ProductsController>();

    return Obx(() {
      if (ctrl.items.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 72, color: Globals.hint),
              SizedBox(height: 16),
              Text(
                'No tienes productos en tu pedido',
                style: TextStyle(color: Globals.hint, fontSize: 16),
              ),
            ],
          ),
        );
      }

      final itemList = ctrl.items.values.toList();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _confirmClear,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Globals.error,
                    size: 18,
                  ),
                  label: const Text(
                    'Limpiar pedido',
                    style: TextStyle(color: Globals.error),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: itemList.length,
              itemBuilder: (context, index) => _OrderItemTile(
                item: itemList[index],
                assetPath: productsCtrl.getAssetPathForProduct(
                  itemList[index].product,
                ),
                onAdd: () => ctrl.addProduct(itemList[index].product),
                onRemove: () => ctrl.removeOne(itemList[index].product.id),
                onDelete: () => ctrl.removeProduct(itemList[index].product.id),
              ),
            ),
          ),
          _CartSummary(ctrl: ctrl),
        ],
      );
    });
  }

  void _confirmClear() {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Limpiar pedido'),
        content: const Text(
          '¿Seguro que quieres eliminar todos los productos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Globals.error),
            onPressed: () {
              ctrl.clearCart();
              Get.back<void>();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}

// ── TAB 2: Historial ──────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.ctrl});

  final OrdersController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingHistory.value) {
        return const Center(
          child: CircularProgressIndicator(color: Globals.primary),
        );
      }

      if (ctrl.historyError.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 56, color: Globals.hint),
              const SizedBox(height: 16),
              Text(
                ctrl.historyError.value,
                style: const TextStyle(color: Globals.hint),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: ctrl.loadOrderHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(backgroundColor: Globals.primary),
              ),
            ],
          ),
        );
      }

      if (ctrl.orderHistory.isEmpty) {
        final emptyMessage = ctrl.isCleaner
            ? 'Todavía no tienes pedidos realizados'
            : 'Aún no tienes pedidos registrados';
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 72,
                color: Globals.hint,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(color: Globals.hint, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: ctrl.loadOrderHistory,
                icon: const Icon(Icons.refresh, color: Globals.primary),
                label: const Text(
                  'Actualizar',
                  style: TextStyle(color: Globals.primary),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: Globals.primary,
        onRefresh: ctrl.loadOrderHistory,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: ctrl.orderHistory.length,
          itemBuilder: (context, index) {
            final order = ctrl.orderHistory[index];
            return _OrderHistoryCard(
              order: order,
              onTap: () => _showOrderDetail(order),
            );
          },
        ),
      );
    });
  }

  void _showOrderDetail(OrderHistoryModel order) {
    Get.bottomSheet<void>(
      Container(
        decoration: const BoxDecoration(
          color: Globals.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _OrderDetailSheet(order: order, isAdmin: ctrl.isAdmin),
      ),
      isScrollControlled: true,
      backgroundColor: Globals.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

// ── Tarjeta de historial (una por pedido) ──────────────────────────────────────

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order, required this.onTap});

  final OrderHistoryModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = OrderHistoryItemModel.statusColor(order.statusCode);
    final statusLabel = OrderHistoryItemModel.statusLabel(order.statusCode);
    final count = order.items.length;
    final summary = count == 0
        ? 'Sin productos'
        : count == 1
            ? '${order.items.first.product.name}  ·  ×${order.items.first.quantity}'
            : '${order.items.length} productos';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            summary,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(label: statusLabel, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      OrderHistoryItemModel.formatDate(order.createdAt),
                      style: const TextStyle(fontSize: 11, color: Globals.hint),
                    ),
                    if (order.reason != null && order.reason!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Motivo: ${order.reason}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Globals.error,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Globals.hint),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge de estado ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Bottom sheet de detalle (pedido con varios productos) ──────────────────────

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({required this.order, required this.isAdmin});

  final OrderHistoryModel order;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final statusColor = OrderHistoryItemModel.statusColor(order.statusCode);
    final statusLabel = OrderHistoryItemModel.statusLabel(order.statusCode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Globals.hint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalle del pedido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _StatusBadge(label: statusLabel, color: statusColor),
              ],
            ),
            const Divider(height: 24),

            // Fecha
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha',
              value: OrderHistoryItemModel.formatDate(order.createdAt),
            ),
            const SizedBox(height: 16),

            // Motivo (solo si está rechazado)
            if (order.reason != null && order.reason!.isNotEmpty) ...[
              _DetailRow(
                icon: Icons.info_outline,
                label: 'Motivo',
                value: order.reason!,
                valueColor: Globals.error,
              ),
              const SizedBox(height: 16),
            ],

            // Lista de productos del pedido
            Text(
              'Productos (${order.items.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Globals.hint,
              ),
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Globals.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        size: 18,
                        color: Globals.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${entry.product.unitOfMeasure}  ·  ×${entry.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Globals.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Acciones de admin (solo pedidos pendientes)
            if (order.statusCode == 0 && isAdmin) ...[
              const Divider(height: 24),
              _AdminActions(order: order),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Acciones de admin (finalizar / rechazar) ──────────────────────────────────

class _AdminActions extends StatelessWidget {
  const _AdminActions({required this.order});

  final OrderHistoryModel order;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrdersController>();

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: ctrl.isActionLoading.value
                  ? null
                  : () => _confirmReject(ctrl),
              icon: const Icon(Icons.cancel_outlined, color: Globals.error),
              label: const Text(
                'Rechazar',
                style: TextStyle(color: Globals.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Globals.error),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: ctrl.isActionLoading.value
                  ? null
                  : () => _confirmFinalize(ctrl),
              icon: ctrl.isActionLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Globals.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                ctrl.isActionLoading.value ? 'Procesando...' : 'Finalizar',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Globals.success,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmFinalize(OrdersController ctrl) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Finalizar pedido'),
        content: const Text(
          '¿Confirmas que deseas finalizar este pedido? Se descontará el stock de los productos.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Globals.success),
            onPressed: () {
              Get.back<void>();
              ctrl.finalizeOrder(order.id);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _confirmReject(OrdersController ctrl) {
    final reasonCtrl = TextEditingController();
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Rechazar pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Deseas rechazar este pedido?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Globals.error),
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              Get.back<void>();
              ctrl.rejectOrder(order.id, reason: reason.isEmpty ? null : reason);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Globals.hint),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Globals.hint, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tile de item del carrito ──────────────────────────────────────────────────

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.item,
    required this.assetPath,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  final OrderItemModel item;
  final String? assetPath;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = item.product.images.isNotEmpty;
    final hasAsset =
        !hasNetworkImage && assetPath != null && assetPath!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Globals.primary.withValues(alpha: 0.15),
              backgroundImage: hasNetworkImage
                  ? NetworkImage(item.product.images.first.url)
                  : hasAsset
                  ? AssetImage(assetPath!)
                  : null,
              child: (hasNetworkImage || hasAsset)
                  ? null
                  : const Icon(Icons.inventory_2, color: Globals.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    item.product.unitOfMeasure,
                    style: const TextStyle(fontSize: 12, color: Globals.hint),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onPressed: onRemove,
                  color: Globals.primary,
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  onPressed: onAdd,
                  color: Globals.primary,
                ),
                const SizedBox(width: 4),
                _CircleButton(
                  icon: Icons.delete_outline,
                  onPressed: onDelete,
                  color: Globals.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ── Resumen + botón confirmar ─────────────────────────────────────────────────

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.ctrl});

  final OrdersController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Globals.white,
        boxShadow: [
          BoxShadow(
            color: Globals.shadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Productos distintos:',
                style: TextStyle(color: Globals.hint),
              ),
              Obx(
                () => Text(
                  '${ctrl.items.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total unidades:',
                style: TextStyle(color: Globals.hint),
              ),
              Obx(
                () => Text(
                  '${ctrl.totalItems}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Globals.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => FilledButton.icon(
              onPressed: ctrl.isSubmitting.value ? null : ctrl.confirmOrder,
              style: FilledButton.styleFrom(
                backgroundColor: Globals.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: ctrl.isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Globals.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                ctrl.isSubmitting.value ? 'Enviando...' : 'Confirmar pedido',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
