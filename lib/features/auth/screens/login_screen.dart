import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final senha = _senhaController.text;

    if (email == 'usuario@desapegai.com' &&
        senha == '12345678') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/inicio',
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail ou senha incorretos.'),
        ),
      );
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
            // E-mail
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'voce@email.com',
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe seu e-mail.';
                }

                if (!valor.contains('@') ||
                    !valor.contains('.')) {
                  return 'Informe um e-mail válido.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // Senha
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

            // Recuperação de senha
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/recuperar-senha',
                  );
                },
                child: const Text('Esqueci minha senha'),
              ),
            ),

            const SizedBox(height: 12),

            // Botão de login
            FilledButton(
              onPressed: _entrar,
              child: const Text('Entrar'),
            ),

            const SizedBox(height: 16),

            // Cadastro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ainda não tem conta?'),
                TextButton(
                  onPressed: () {
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