import 'package:flutter/material.dart';
import 'features/auth/screens/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/recover_password_screen.dart';
import 'features/auth/screens/register_screen.dart';

class DesapegaiApp extends StatelessWidget {
  const DesapegaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desapegaí',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const RegisterScreen(),
        '/recuperar-senha': (context) => const RecoverPasswordScreen(),
        '/inicio': (context) => const HomeScreen(),
      },
    );
  }
}
