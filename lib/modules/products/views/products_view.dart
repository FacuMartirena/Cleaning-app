import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/product_model.dart';
import 'package:bo_cleaning/modules/orders/controllers/orders_controller.dart';
import 'package:bo_cleaning/modules/products/controllers/products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersCtrl = Get.find<OrdersController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Globals.primary,
        foregroundColor: Globals.white,
      ),
      drawer: Drawer(
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
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
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
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => Get.offAllNamed(AppRoutes.login),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        final count = ordersCtrl.totalItems;
        if (count == 0) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.orders),
          backgroundColor: Globals.primary,
          foregroundColor: Globals.white,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined),
              Positioned(
                top: -6,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Globals.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Globals.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: const Text('Ver pedido'),
        );
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Globals.primary),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => controller.loadProducts(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        if (controller.products.isEmpty) {
          return const Center(child: Text('No hay productos'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.products.length,
          itemBuilder: (context, index) => _ProductTile(
            product: controller.products[index],
            assetPath: controller.getAssetPathForProduct(
              controller.products[index],
            ),
            ordersCtrl: ordersCtrl,
          ),
        );
      }),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.assetPath,
    required this.ordersCtrl,
  });

  final ProductModel product;
  final String? assetPath;
  final OrdersController ordersCtrl;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = product.images.isNotEmpty;
    final hasAsset =
        !hasNetworkImage && assetPath != null && assetPath!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Globals.primary.withValues(alpha: 0.2),
              backgroundImage: hasNetworkImage
                  ? NetworkImage(product.images.first.url)
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
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'cant: ${product.quantityAvailable}',
                    style: const TextStyle(fontSize: 12, color: Globals.hint),
                  ),
                  Text(
                    'presentacion: ${product.unitOfMeasure}',
                    style: const TextStyle(fontSize: 12, color: Globals.hint),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => _QuantitySelector(
                  quantity: ordersCtrl.quantityOf(product.id),
                  onAdd: () => ordersCtrl.addProduct(product),
                  onRemove: () => ordersCtrl.removeOne(product.id),
                )),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Globals.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallIconButton(
            icon: Icons.remove,
            onPressed: quantity > 0 ? onRemove : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Globals.primary,
              ),
            ),
          ),
          _SmallIconButton(icon: Icons.add, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = onPressed != null ? Globals.primary : Globals.hint;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
