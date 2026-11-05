import 'package:flutter/material.dart';

import '../../../core/widgets/auth_layout.dart';

class RecoverPasswordScreen extends StatelessWidget {
  const RecoverPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Recuperar senha',
      subtitle: 'Informe seu e-mail para recuperar o acesso à conta.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail cadastrado',
              hintText: 'voce@email.com',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recuperação de senha será implementada em uma próxima etapa.')),
              );
            },
            child: const Text('Solicitar recuperação'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar ao login'),
          ),
        ],
      ),
    );
  }
}
