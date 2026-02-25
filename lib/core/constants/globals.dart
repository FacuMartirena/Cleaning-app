import 'package:flutter/material.dart';

abstract class Globals {
  // --- API Base URL ---
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // --- Auth endpoints ---
  static const String authLogin = '/auth/login';
  static const String authCurrentUser = '/auth/current-user';
  static const String authRefreshToken = '/auth/refresh-token';

  // --- Storage keys ---
  static const String storageToken = 'token';
  static const String storageUser = 'user';

  // --- Headers ---
  static String authorizationBearer(String token) => 'Bearer $token';

  // --- Styles ---
  static const Color primary = Color(0xFF006EAA);
  static const Color hint = Color(0xFFB0BEC5);
  static const Color gradientStart = Color(0xFF1DA2FC);
  static const Color gradientEnd = Color(0xFF42D0FD);
}
