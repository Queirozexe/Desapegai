import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/sessao_control.dart';
import '../controller/usuario_control.dart';
import '../model/usuario.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'completar_perfil_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final SessaoControl _sessaoControl;
  late final UsuarioControl _usuarioControl;

  Future<Usuario?>? _perfilFuture;
  String? _uidPerfilConsultado;

  @override
  void initState() {
    super.initState();
    _sessaoControl = SessaoControl();
    _usuarioControl = UsuarioControl();
  }

  void _iniciarConsultaPerfil(String uid) {
    if (_uidPerfilConsultado == uid && _perfilFuture != null) {
      return;
    }

    _uidPerfilConsultado = uid;
    _perfilFuture = _usuarioControl.buscarUsuarioAtual();
  }

  void _reconsultarPerfil() {
    final usuarioAtual = FirebaseAuth.instance.currentUser;

    if (usuarioAtual == null || !mounted) return;

    setState(() {
      _uidPerfilConsultado = usuarioAtual.uid;
      _perfilFuture = _usuarioControl.buscarUsuarioAtual();
    });
  }

  Widget _construirCarregamento() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _construirErroPerfil() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Não foi possível verificar os dados do seu perfil.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _reconsultarPerfil,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _sessaoControl.estadoAutenticacao,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _construirCarregamento();
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

        final usuarioAutenticado = snapshot.data;

        if (usuarioAutenticado == null) {
          _uidPerfilConsultado = null;
          _perfilFuture = null;

          return const LoginScreen();
        }

        _iniciarConsultaPerfil(usuarioAutenticado.uid);

        return FutureBuilder<Usuario?>(
          future: _perfilFuture,
          builder: (context, perfilSnapshot) {
            if (perfilSnapshot.connectionState ==
                ConnectionState.waiting) {
              return _construirCarregamento();
            }

            if (perfilSnapshot.hasError) {
              return _construirErroPerfil();
            }

            final usuario = perfilSnapshot.data;

            if (usuario != null) {
              return const HomeScreen();
            }

            return CompletarPerfilScreen(
              onPerfilCriado: _reconsultarPerfil,
            );
          },
        );
      },
    );
  }
}
