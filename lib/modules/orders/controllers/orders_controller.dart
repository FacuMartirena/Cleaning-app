import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/order_item_model.dart';
import 'package:bo_cleaning/core/models/order_model.dart'
    show OrderHistoryModel;
import 'package:bo_cleaning/core/models/product_model.dart';
import 'package:bo_cleaning/core/models/user_model.dart';
import 'package:bo_cleaning/core/services/auth_service.dart';
import 'package:bo_cleaning/modules/orders/services/orders_provider.dart';
import 'package:bo_cleaning/modules/users/services/users_provider.dart';

class OrdersController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final OrdersProvider _provider = Get.find<OrdersProvider>();
  final AuthService _auth = Get.find<AuthService>();
  final UsersProvider _usersProvider = Get.find<UsersProvider>();

  // ── Tabs controller ───────────────────────────────────────────────────────────
  late final TabController tabController;

  // ── Carro ────────────────────────────────────────────────────────────────────
  final items = <String, OrderItemModel>{}.obs;
  final isSubmitting = false.obs;

  /// Solo admins: usuario para el cual se realiza el pedido. null = yo mismo.
  final orderOnBehalfOfUserId = Rxn<String>();

  /// Lista de usuarios (Limpiador/Administrativo) para el dropdown de "pedido a nombre de".
  final usersForOrder = <UserModel>[].obs;
  final isLoadingUsersForOrder = false.obs;

  // ── Historial de pedidos ────────────────────────────────────────────────────
  final orderHistory = <OrderHistoryModel>[].obs;
  final isLoadingHistory = false.obs;
  final historyError = ''.obs;
  final isActionLoading = false.obs;

  bool get isAdmin => _auth.isAdmin;

  /// Nombre completo del usuario actual (para la opción "pedido a mi nombre").
  String get currentUserFullName {
    final name = _auth.userFullName;
    return name.isNotEmpty ? name : 'Yo mismo';
  }

  bool get isCleaner => (_auth.userRole ?? '') == 'Limpiador';

  /// Selecciona la pestaña de carrito / \"Mi pedido\".
  void goToCartTab() => tabController.index = 0;

  /// Resetea por completo el estado de pedidos (carrito + historial).
  void resetState() {
    items.clear();
    orderHistory.clear();
    orderOnBehalfOfUserId.value = null;
    usersForOrder.clear();
  }

  @override
  void onInit() {
    super.onInit();
    // Resetear estado cuando el usuario cierra sesión.
    ever<bool>(_auth.isLoggedIn, (loggedIn) {
      if (!loggedIn) {
        resetState();
      }
    });

    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging && tabController.index == 1) {
        // Siempre recargar historial al entrar a la pestaña de historial,
        // para evitar ver pedidos de un usuario anterior.
        if (!isLoadingHistory.value) {
          loadOrderHistory();
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    if (isAdmin) loadUsersForOrder();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  int get totalItems =>
      items.values.fold(0, (sum, item) => sum + item.quantity);

  bool hasProduct(String productId) => items.containsKey(productId);

  int quantityOf(String productId) => items[productId]?.quantity ?? 0;

  void addProduct(ProductModel product) {
    if (items.containsKey(product.id)) {
      items[product.id]!.quantity++;
      items.refresh();
    } else {
      items[product.id] = OrderItemModel(product: product, quantity: 1);
    }
  }

  void removeOne(String productId) {
    if (!items.containsKey(productId)) return;
    if (items[productId]!.quantity <= 1) {
      items.remove(productId);
    } else {
      items[productId]!.quantity--;
      items.refresh();
    }
  }

  void removeProduct(String productId) => items.remove(productId);

  void clearCart() => items.clear();

  /// Carga usuarios Limpiador y Administrativo para que el admin pueda hacer pedidos a su nombre.
  Future<void> loadUsersForOrder() async {
    if (!isAdmin) return;
    isLoadingUsersForOrder.value = true;
    try {
      final response = await _usersProvider.getUsers();
      if (response.statusCode == 200) {
        final body = response.body;
        List<dynamic> list;
        if (body is List) {
          list = body;
        } else if (body is Map && body['data'] is List) {
          list = body['data'] as List;
        } else {
          list = [];
        }
        final all = list
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .where((u) => u.role == 'Limpiador' || u.role == 'Administrativo')
            .toList();
        usersForOrder.value = all;
        if (orderOnBehalfOfUserId.value != null &&
            !all.any((u) => u.id == orderOnBehalfOfUserId.value)) {
          orderOnBehalfOfUserId.value = null;
        }
      }
    } catch (_) {
      usersForOrder.clear();
    } finally {
      isLoadingUsersForOrder.value = false;
    }
  }

  Future<void> confirmOrder() async {
    if (items.isEmpty) return;

    final userId = isAdmin && orderOnBehalfOfUserId.value != null
        ? orderOnBehalfOfUserId.value!
        : _auth.userId;
    if (userId == null || userId.isEmpty) {
      Get.snackbar(
        'Error',
        'No se pudo identificar al usuario. Vuelve a iniciar sesión.',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'userId': userId,
        'items': items.values.map((e) => e.toJson()).toList(),
        if (_auth.companyId != null && _auth.companyId!.isNotEmpty)
          'companyId': _auth.companyId,
      };

      final response = await _provider.createOrder(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearCart();
        // Refresh history so the new order appears immediately
        orderHistory.clear();
        Get.snackbar(
          'Pedido enviado',
          'Tu pedido fue creado exitosamente',
          backgroundColor: Globals.success,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        final message =
            response.body?['message']?.toString() ?? 'Error al crear el pedido';
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo conectar con el servidor',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Historial de pedidos ────────────────────────────────────────────────────

  Future<void> loadOrderHistory() async {
    final hasCompany = (_auth.companyId ?? '').isNotEmpty;

    final userId = _auth.userId;
    if (userId == null || userId.isEmpty) {
      historyError.value =
          'No se pudo identificar al usuario. Vuelve a iniciar sesión.';
      return;
    }

    if (!isCleaner) {
      // Para administradores/administrativos exigimos una empresa seleccionada.
      if (!hasCompany) {
        historyError.value =
            'Debes seleccionar una empresa antes de ver el historial de pedidos.';
        return;
      }
    }

    isLoadingHistory.value = true;
    historyError.value = '';

    try {
      // Staff (admin/administrativo): todos los pedidos de la empresa para aceptar/rechazar.
      // Limpiador: solo sus propios pedidos.
      final response = isCleaner
          ? await _provider.getOrders(userId: userId)
          : await _provider.getOrders(companyId: _auth.companyId);

      if (response.statusCode == 200) {
        final body = response.body;
        List<dynamic> data;
        if (body is List) {
          data = body;
        } else if (body is Map && body['data'] is List) {
          data = body['data'] as List;
        } else {
          data = [];
        }
        orderHistory.value = data
            .map(
              (e) =>
                  OrderHistoryModel.fromJsonOrLegacy(e as Map<String, dynamic>),
            )
            .toList();
      } else {
        historyError.value =
            response.body?['message']?.toString() ??
            'Error al cargar el historial de pedidos';
      }
    } catch (_) {
      historyError.value = 'No se pudo conectar con el servidor';
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ── Acciones de administrador ─────────────────────────────────────────────────

  Future<void> finalizeOrder(String orderId) async {
    isActionLoading.value = true;
    try {
      final response = await _provider.finalizeOrder(orderId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back<void>();
        await loadOrderHistory();
        Get.snackbar(
          'Pedido finalizado',
          'El pedido fue completado exitosamente.',
          backgroundColor: Globals.success,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        final message =
            response.body?['message']?.toString() ??
            'Error al finalizar el pedido';
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo conectar con el servidor',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> rejectOrder(String orderId, {String? reason}) async {
    isActionLoading.value = true;
    try {
      final response = await _provider.rejectOrder(orderId, reason: reason);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back<void>();
        await loadOrderHistory();
        Get.snackbar(
          'Pedido rechazado',
          'El pedido fue rechazado.',
          backgroundColor: Globals.pending,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        final message =
            response.body?['message']?.toString() ??
            'Error al rechazar el pedido';
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Globals.error,
          colorText: Globals.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo conectar con el servidor',
        backgroundColor: Globals.error,
        colorText: Globals.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionLoading.value = false;
    }
  }
}
