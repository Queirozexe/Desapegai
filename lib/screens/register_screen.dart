import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/cadastro_control.dart';
import '../widgets/auth_layout.dart';
import '../widgets/botoes.dart';
import '../widgets/input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _senhaController = TextEditingController();

  final CadastroControl _cadastroControl = CadastroControl();

  bool _aceitouTermos = false;
  bool _estaCarregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cidadeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    if (_estaCarregando) return;

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

    setState(() {
      _estaCarregando = true;
    });

    try {
      await _cadastroControl.cadastrarUsuario(
        nome: _nomeController.text,
        email: _emailController.text,
        cidade: _cidadeController.text,
        senha: _senhaController.text,
      );

      if (!mounted) return;

      Navigator.popUntil(
        context,
            (route) => route.isFirst,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;

      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este e-mail já está cadastrado.';
          break;
        case 'invalid-email':
          mensagem = 'O endereço de e-mail informado é inválido.';
          break;
        case 'weak-password':
          mensagem = 'A senha informada é muito fraca.';
          break;
        case 'operation-not-allowed':
          mensagem = 'O cadastro por e-mail e senha não está habilitado.';
          break;
        case 'network-request-failed':
          mensagem = 'Falha de conexão. Verifique sua internet.';
          break;
        case 'too-many-requests':
          mensagem = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        default:
          mensagem = 'Não foi possível criar sua conta. Tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e, stackTrace) {
      debugPrint('Erro durante o cadastro: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro inesperado ao criar sua conta.'),
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
            onChanged: _estaCarregando
                ? null
                : (valor) {
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
            _estaCarregando ? 'Criando conta...' : 'Criar conta',
            onPressed: _estaCarregando ? null : _criarConta,
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: _estaCarregando
                ? null
                : () => Navigator.pop(context),
            child: const Text('Já tem conta? Entrar'),
          ),
        ],
      ),
    );
  }
}
