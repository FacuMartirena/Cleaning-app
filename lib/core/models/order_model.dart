import 'package:flutter/material.dart';

import 'package:bo_cleaning/core/constants/globals.dart';
import 'package:bo_cleaning/core/models/product_model.dart';

/// Un ítem dentro de una orden en el historial (producto + cantidad).
class OrderHistoryItemEntry {
  final String id;
  final ProductModel product;
  final int quantity;

  const OrderHistoryItemEntry({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory OrderHistoryItemEntry.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    return OrderHistoryItemEntry(
      id: json['id']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
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
}

/// Una orden completa (un pedido) con su lista de productos.
class OrderHistoryModel {
  final String id;
  final int statusCode; // 0=Pendiente 1=Finalizado 2=Rechazado
  final DateTime createdAt;
  final String? reason;
  final List<OrderHistoryItemEntry> items;

  const OrderHistoryModel({
    required this.id,
    required this.statusCode,
    required this.createdAt,
    this.reason,
    required this.items,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderHistoryModel(
      id: json['id']?.toString() ?? '',
      statusCode:
          (json['statusCode'] as num?)?.toInt() ??
          (json['status'] as num?)?.toInt() ??
          0,
      createdAt:
          DateTime.tryParse(
            json['createdAt']?.toString() ?? json['date']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now(),
      reason: json['reason']?.toString(),
      items: itemsJson
          .map((e) => OrderHistoryItemEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parsea un elemento: si tiene "items" es una orden nueva; si no, legacy (1 ítem).
  static OrderHistoryModel fromJsonOrLegacy(Map<String, dynamic> json) {
    if (json['items'] is List) {
      return OrderHistoryModel.fromJson(json);
    }
    final single = OrderHistoryItemEntry.fromJson(json);
    return OrderHistoryModel(
      id: json['id']?.toString() ?? single.id,
      statusCode:
          (json['statusCode'] as num?)?.toInt() ??
          (json['status'] as num?)?.toInt() ??
          0,
      createdAt:
          DateTime.tryParse(
            json['createdAt']?.toString() ?? json['date']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now(),
      reason: json['reason']?.toString(),
      items: [single],
    );
  }
}

/// Representa un ítem de orden tal como lo devuelve el backend (formato legacy).
class OrderHistoryItemModel {
  final String id;
  final int quantity;
  final DateTime date;
  final int statusCode; // 0=Pendiente 1=Finalizado 2=Rechazado
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
          DateTime.tryParse(json['date']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
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
        return 'Finalizado';
      case 2:
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  static Color statusColor(int code) {
    switch (code) {
      case 0:
        return Globals.pending;
      case 1:
        return Globals.success;
      case 2:
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
