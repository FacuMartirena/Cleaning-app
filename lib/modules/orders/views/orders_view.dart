import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/order_item_model.dart';
import 'package:bo_cleaning/modules/orders/controllers/orders_controller.dart';
import 'package:bo_cleaning/modules/products/controllers/products_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final productsCtrl = Get.find<ProductsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi pedido'),
        backgroundColor: Globals.primary,
        foregroundColor: Globals.white,
        actions: [
          Obx(
            () => controller.items.isNotEmpty
                ? TextButton.icon(
                    onPressed: () => _confirmClear(context),
                    icon: const Icon(Icons.delete_outline, color: Globals.white),
                    label: const Text(
                      'Limpiar',
                      style: TextStyle(color: Globals.white),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
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

        final itemList = controller.items.values.toList();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: itemList.length,
                itemBuilder: (context, index) => _OrderItemTile(
                  item: itemList[index],
                  assetPath: productsCtrl
                      .getAssetPathForProduct(itemList[index].product),
                  onAdd: () =>
                      controller.addProduct(itemList[index].product),
                  onRemove: () =>
                      controller.removeOne(itemList[index].product.id),
                  onDelete: () =>
                      controller.removeProduct(itemList[index].product.id),
                ),
              ),
            ),
            _OrderSummary(controller: controller),
          ],
        );
      }),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpiar pedido'),
        content:
            const Text('¿Seguro que quieres eliminar todos los productos?'),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Globals.error),
            onPressed: () {
              controller.clearCart();
              Get.back<void>();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}

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

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.controller});

  final OrdersController controller;

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
                  '${controller.items.length}',
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
                  '${controller.totalItems}',
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
              onPressed:
                  controller.isSubmitting.value ? null : controller.confirmOrder,
              style: FilledButton.styleFrom(
                backgroundColor: Globals.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: controller.isSubmitting.value
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
                controller.isSubmitting.value
                    ? 'Enviando...'
                    : 'Confirmar pedido',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
