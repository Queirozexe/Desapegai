
import 'package:flutter/material.dart';

import '../controller/recuperacao_senha_control.dart';
import '../widgets/auth_layout.dart';
import '../widgets/botoes.dart';
import '../widgets/input.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() =>
      _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState
    extends State<RecoverPasswordScreen> {

  final _emailController = TextEditingController();

  final RecuperacaoSenhaControl _recuperacaoControl =
  RecuperacaoSenhaControl();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _recuperarSenha() {
    final erro = _recuperacaoControl.validarEmail(
      _emailController.text,
    );

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'E-mail válido! O envio do link será '
              'ativado após a integração com o Firebase.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Esqueceu a senha?',
      subtitle:
      'Informe o e-mail da sua conta e '
          'enviaremos um link para você criar '
          'uma nova senha.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Input(
            'E-mail cadastrado',
            'voce@email.com',
            controller: _emailController,
          ),

          const SizedBox(height: 24),

          Botoes(
            'Enviar link de recuperação',
            onPressed: _recuperarSenha,
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Voltar ao login'),
          ),
        ],
      ),
    );
  }
}
