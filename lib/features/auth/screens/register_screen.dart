import 'package:flutter/material.dart';

import '../../../core/widgets/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _aceitouTermos = false;

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Criar conta',
      subtitle: 'Preencha suas informações para começar.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: 'Nome completo'),
          ),
          const SizedBox(height: 16),
          const TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: 'E-mail'),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Cidade'),
          ),
          const SizedBox(height: 16),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Senha'),
          ),
          const SizedBox(height: 16),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Confirmar senha'),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _aceitouTermos,
            onChanged: (valor) => setState(() => _aceitouTermos = valor ?? false),
            title: const Text('Li e aceito os termos de uso e a política de privacidade.'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cadastro será implementado em uma próxima etapa.')),
              );
            },
            child: const Text('Criar conta'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Já tenho conta — voltar ao login'),
          ),
        ],
      ),
    );
  }
}
