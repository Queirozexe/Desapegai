import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';
import '../controller/login_control.dart';
import '../widgets/botoes.dart';
import '../widgets/input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final LoginControl _loginControl = LoginControl();

  bool _estaCarregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_estaCarregando) return;

    final email = _emailController.text.trim().toLowerCase();
    final senha = _senhaController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe seu e-mail.'),
        ),
      );
      return;
    }

    final emailValido = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(email);

    if (!emailValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um e-mail válido.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    try {
      await _loginControl.entrar(
        email: email,
        senha: senha,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;

      switch (e.code) {
        case 'invalid-email':
          mensagem = 'O endereço de e-mail informado é inválido.';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          mensagem = 'E-mail ou senha incorretos.';
          break;
        case 'user-disabled':
          mensagem = 'Esta conta está desativada.';
          break;
        case 'too-many-requests':
          mensagem = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        case 'network-request-failed':
          mensagem = 'Falha de conexão. Verifique sua internet.';
          break;
        case 'operation-not-allowed':
          mensagem = 'O login por e-mail e senha não está habilitado.';
          break;
        default:
          mensagem = 'Não foi possível entrar. Tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e, stackTrace) {
      debugPrint('Erro durante o login: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro inesperado ao entrar.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _estaCarregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBrand: true,
      title: 'Entrar',
      subtitle: 'Acesse sua conta para continuar.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Input(
              'E-mail',
              'voce@email.com',
              controller: _emailController,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Informe sua senha.';
                }

                if (valor.length < 8) {
                  return 'A senha deve ter ao menos 8 caracteres.';
                }

                return null;
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _estaCarregando
                    ? null
                    : () {
                  Navigator.pushNamed(
                    context,
                    '/recuperar-senha',
                  );
                },
                child: const Text('Esqueci minha senha'),
              ),
            ),

            const SizedBox(height: 12),

            Botoes(
              _estaCarregando ? 'Entrando...' : 'Entrar',
              onPressed: _estaCarregando ? null : _entrar,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ainda não tem conta?'),
                TextButton(
                  onPressed: _estaCarregando
                      ? null
                      : () {
                    Navigator.pushNamed(
                      context,
                      '/cadastro',
                    );
                  },
                  child: const Text('Criar conta'),
                ),
              ],
            ),

            const SizedBox(height: 64),

            const Text(
              'Doação gratuita, sem venda e sem '
                  'intermediação financeira.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
