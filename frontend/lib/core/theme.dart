import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: Colors.green,
  );
}