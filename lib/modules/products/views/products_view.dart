import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/config/router/app_routes.dart';
import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/widgets/app_drawer.dart';
import 'package:bo_cleaning/core/models/product_model.dart';
import 'package:bo_cleaning/modules/orders/controllers/orders_controller.dart';
import 'package:bo_cleaning/modules/products/controllers/products_controller.dart';
import 'package:bo_cleaning/modules/products/widgets/add_product_sheet.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  void _showAddStockDialog(ProductModel product) {
    controller.openAddStockDialog(product);
    Get.dialog<void>(
      AlertDialog(
        title: Text('Agregar stock: ${product.name}'),
        content: TextField(
          controller: controller.addStockAmountController,
          focusNode: controller.addStockFocusNode,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Cantidad a agregar',
            hintText: '0',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            Get.back<void>();
            controller.submitAddStock();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back<void>();
              controller.submitAddStock();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showAddProductSheet() {
    controller.openCreateProductSheet();
    Get.bottomSheet<void>(
      DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Globals.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AddProductSheet(scrollController: scrollController),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Globals.transparent,
      ignoreSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersCtrl = Get.find<OrdersController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Globals.primary,
        foregroundColor: Globals.white,
        actions: [
          if (controller.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Agregar producto',
              onPressed: _showAddProductSheet,
            ),
        ],
      ),
      drawer: const AppDrawer(),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o presentación',
                hintStyle: const TextStyle(color: Globals.hint, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Globals.hint),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Globals.hint),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.onSearchChanged('');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: Globals.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Globals.hint),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Globals.hint),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Globals.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
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

              final hasSearch = controller.searchQuery.value.isNotEmpty;

              if (controller.products.isEmpty) {
                return Center(
                  child: Text(
                    hasSearch
                        ? 'Sin resultados para "${controller.searchQuery.value}"'
                        : 'No hay productos',
                    style: const TextStyle(color: Globals.hint, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.products.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= controller.products.length) {
                      return Obx(() {
                        if (controller.isLoadingMore.value) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (!controller.hasMore.value) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No hay más productos',
                                style: TextStyle(
                                  color: Globals.hint,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      });
                    }
                    final product = controller.products[index];
                    return _ProductTile(
                      product: product,
                      assetPath: controller.getAssetPathForProduct(product),
                      ordersCtrl: ordersCtrl,
                      isAdmin: controller.isAdmin,
                      onAddStock: () => _showAddStockDialog(product),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.assetPath,
    required this.ordersCtrl,
    required this.isAdmin,
    required this.onAddStock,
  });

  final ProductModel product;
  final String? assetPath;
  final OrdersController ordersCtrl;
  final bool isAdmin;
  final VoidCallback onAddStock;

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
            if (isAdmin) ...[
              IconButton(
                onPressed: onAddStock,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Globals.primary,
                ),
                tooltip: 'Agregar stock',
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Obx(
              () => _QuantitySelector(
                quantity: ordersCtrl.quantityOf(product.id),
                onAdd: () => ordersCtrl.addProduct(product),
                onRemove: () => ordersCtrl.removeOne(product.id),
              ),
            ),
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
