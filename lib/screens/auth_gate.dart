import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/sessao_control.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final SessaoControl _sessaoControl;

  @override
  void initState() {
    super.initState();
    _sessaoControl = SessaoControl();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _sessaoControl.estadoAutenticacao,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Não foi possível verificar sua sessão.',
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
