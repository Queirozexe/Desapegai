import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'screens/recover_password_screen.dart';
import 'screens/register_screen.dart';
import 'theme/app_theme.dart';

class DesapegaiApp extends StatelessWidget {
  const DesapegaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desapegaí',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: {
        '/cadastro': (context) => const RegisterScreen(),
        '/recuperar-senha': (context) =>
        const RecoverPasswordScreen(),
      },
    );
  }
}
