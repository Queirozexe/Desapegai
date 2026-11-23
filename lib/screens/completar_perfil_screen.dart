import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/usuario_control.dart';
import '../controller/sessao_control.dart';
import '../widgets/auth_layout.dart';
import '../widgets/botoes.dart';
import '../widgets/input.dart';

class CompletarPerfilScreen extends StatefulWidget {
  final VoidCallback onPerfilCriado;

  const CompletarPerfilScreen({
    super.key,
    required this.onPerfilCriado,
  });

  @override
  State<CompletarPerfilScreen> createState() =>
      _CompletarPerfilScreenState();
}

class _CompletarPerfilScreenState
    extends State<CompletarPerfilScreen> {
  final UsuarioControl _usuarioControl = UsuarioControl();
  final SessaoControl _sessaoControl = SessaoControl();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController =
  TextEditingController();

  final TextEditingController _cidadeController =
  TextEditingController();

  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfil() async {
    if (_carregando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      await _usuarioControl.criarPerfilSeAusente(
        nome: _nomeController.text,
        cidade: _cidadeController.text,
      );

      if (!mounted) return;

      widget.onPerfilCriado();
    } catch (e, stackTrace) {
      debugPrint('Erro ao recuperar perfil: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar seu perfil. Tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _sair() async {
    if (_carregando) return;

    try {
      await _sessaoControl.sair();
    } catch (e, stackTrace) {
      debugPrint('Erro ao encerrar sessão: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sair da conta.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return AuthLayout(
      title: 'Completar perfil',
      subtitle: 'Precisamos de algumas informações para '
          'configurar sua conta.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'E-mail: $email',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            Input(
              'Nome completo',
              'Digite seu nome completo',
              controller: _nomeController,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe seu nome.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            Input(
              'Cidade',
              'Informe sua cidade',
              controller: _cidadeController,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe sua cidade.';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            Botoes(
              _carregando ? 'Salvando...' : 'Completar perfil',
              onPressed: _carregando ? null : _salvarPerfil,
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: _carregando ? null : _sair,
              child: const Text('Sair da conta'),
            ),
          ],
        ),
      ),
    );
  }
}
