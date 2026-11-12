import 'package:flutter/material.dart';

import '../controller/cadastro_control.dart';
import '../widgets/auth_layout.dart';
import '../widgets/botoes.dart';
import '../widgets/input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _senhaController = TextEditingController();

  final CadastroControl _cadastroControl = CadastroControl();

  bool _aceitouTermos = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cidadeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _criarConta() {
    final erro = _cadastroControl.validarCadastro(
      nome: _nomeController.text,
      email: _emailController.text,
      cidade: _cidadeController.text,
      senha: _senhaController.text,
      aceitouTermos: _aceitouTermos,
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
          'Dados válidos! O cadastro será ativado '
              'após a integração com o Firebase.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Criar conta',
      subtitle: 'Leva menos de um minuto. '
          'É grátis e sempre será.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Input(
            'Nome completo',
            'Digite seu nome completo',
            controller: _nomeController,
          ),

          const SizedBox(height: 16),

          Input(
            'E-mail',
            'voce@email.com',
            controller: _emailController,
          ),

          const SizedBox(height: 16),

          Input(
            'Cidade',
            'Informe sua cidade',
            controller: _cidadeController,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _senhaController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              hintText: 'Mínimo de 8 caracteres',
            ),
          ),

          const SizedBox(height: 16),

          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _aceitouTermos,
            onChanged: (valor) {
              setState(() {
                _aceitouTermos = valor ?? false;
              });
            },
            title: const Text(
              'Li e aceito os termos de uso e a '
                  'política de privacidade, que seguem a LGPD.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),

          const SizedBox(height: 16),

          Botoes(
            'Criar conta',
            onPressed: _criarConta,
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Já tem conta? Entrar'),
          ),
        ],
      ),
    );
  }
}
