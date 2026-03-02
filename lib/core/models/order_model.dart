import 'package:flutter/material.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/product_model.dart';

/// Representa un ítem de orden tal como lo devuelve el backend.
/// GET /api/orders?userId=xxx → List of OrderHistoryItemModel
class OrderHistoryItemModel {
  final String id;
  final int quantity;
  final DateTime date;
  final int statusCode; // 0=Pendiente 1=En proceso 2=Entregado 3=Cancelado
  final String? reason;
  final ProductModel product;

  const OrderHistoryItemModel({
    required this.id,
    required this.quantity,
    required this.date,
    required this.statusCode,
    this.reason,
    required this.product,
  });

  factory OrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    return OrderHistoryItemModel(
      id: json['id']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      date:
          DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      statusCode: (json['status'] as num?)?.toInt() ?? 0,
      reason: json['reason']?.toString(),
      product: productJson != null
          ? ProductModel.fromJson(productJson)
          : ProductModel(
              id: '',
              name: 'Producto',
              unitOfMeasure: '',
              quantityAvailable: 0,
              active: true,
              lastUpdated: '',
            ),
    );
  }

  // ── Status helpers ──────────────────────────────────────────────────────────

  static String statusLabel(int code) {
    switch (code) {
      case 0:
        return 'Pendiente';
      case 1:
        return 'En proceso';
      case 2:
        return 'Entregado';
      case 3:
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  static Color statusColor(int code) {
    switch (code) {
      case 0:
        return Globals.pending;
      case 1:
        return Globals.primary;
      case 2:
        return Globals.success;
      case 3:
        return Globals.error;
      default:
        return Globals.hint;
    }
  }

  // ── Date helper ─────────────────────────────────────────────────────────────

  static String formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}  $h:$min';
  }
}
