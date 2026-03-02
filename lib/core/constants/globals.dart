import 'package:flutter/material.dart';

abstract class Globals {
  // --- API Base URL ---
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // --- Auth endpoints ---
  static const String authLogin = '/auth/login';
  static const String authCurrentUser = '/auth/current-user';
  static const String authRefreshToken = '/auth/refresh-token';

  // --- Users ---
  static const String usersPath = '/users';

  // --- Products ---
  static const String productsPath = '/products';

  // --- Orders ---
  static const String ordersPath = '/orders';

  // --- Storage keys ---
  static const String storageToken = 'token';
  static const String storageUser = 'user';

  // --- Headers ---
  static String authorizationBearer(String token) => 'Bearer $token';

  // --- Colors ---
  static const Color primary = Color(0xFF006EAA);
  static const Color hint = Color(0xFFB0BEC5);
  static const Color gradientStart = Color(0xFF1DA2FC);
  static const Color gradientEnd = Color(0xFF42D0FD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color shadow = Color(0x14000000);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color pending = Color(0xFFFB8C00);
}
