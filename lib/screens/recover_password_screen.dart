import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  bool _estaCarregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _recuperarSenha() async {
    if (_estaCarregando) return;

    final email = _emailController.text.trim().toLowerCase();

    final erro = _recuperacaoControl.validarEmail(email);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    const mensagemSucesso =
        'Se houver uma conta cadastrada com esse endereço, '
        'enviaremos um link para redefinir sua senha.';

    try {
      await _recuperacaoControl.enviarEmailRecuperacao(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(mensagemSucesso),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;

      switch (e.code) {
        case 'user-not-found':
          mensagem = mensagemSucesso;
          break;
        case 'invalid-email':
          mensagem = 'O endereço de e-mail informado é inválido.';
          break;
        case 'too-many-requests':
          mensagem = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        case 'network-request-failed':
          mensagem = 'Falha de conexão. Verifique sua internet.';
          break;
        case 'operation-not-allowed':
          mensagem = 'A recuperação de senha não está habilitada.';
          break;
        default:
          mensagem = 'Não foi possível solicitar a recuperação. '
              'Tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e, stackTrace) {
      debugPrint('Erro durante a recuperação de senha: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocorreu um erro inesperado. Tente novamente.',
          ),
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
      title: 'Esqueceu a senha?',
      subtitle: 'Informe o e-mail da sua conta e '
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
            _estaCarregando
                ? 'Enviando...'
                : 'Enviar link de recuperação',
            onPressed: _estaCarregando ? null : _recuperarSenha,
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: _estaCarregando
                ? null
                : () {
              Navigator.pop(context);
            },
            child: const Text('Voltar ao login'),
          ),
        ],
      ),
    );
  }
}
