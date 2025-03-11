import 'package:chat_app/config/theme/app_theme.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/presentation/auth/login_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}