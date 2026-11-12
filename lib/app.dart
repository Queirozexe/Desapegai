import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/recover_password_screen.dart';
import 'screens/register_screen.dart';

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
