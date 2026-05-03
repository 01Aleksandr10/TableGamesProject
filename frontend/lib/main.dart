import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/api_client.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'features/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await ApiClient.init();
  runApp(ProviderScope(child: TFPApp(isLoggedIn: isLoggedIn)));
}

class TFPApp extends StatelessWidget {
  final bool isLoggedIn;

  const TFPApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFP — Настольные игры',
      theme: AppTheme.darkTheme,
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
