import 'package:flutter/material.dart';

import '../controller/usuario_control.dart';
import '../model/usuario.dart';
import '../widgets/input.dart';
import '../widgets/botoes.dart';

class EditProfileScreen extends StatefulWidget {
  final Usuario usuario;

  const EditProfileScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UsuarioControl _usuarioControl = UsuarioControl();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _cidadeController;
  late final TextEditingController _sobreMimController;

  bool _carregando = false;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(
      text: widget.usuario.nome,
    );

    _cidadeController = TextEditingController(
      text: widget.usuario.cidade,
    );

    _sobreMimController = TextEditingController(
      text: widget.usuario.sobreMim,
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cidadeController.dispose();
    _sobreMimController.dispose();

    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      await _usuarioControl.atualizarUsuario(
        nome: _nomeController.text,
        cidade: _cidadeController.text,
        sobreMim: _sobreMimController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar seu perfil.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Atualize suas informações',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Input(
                'Nome',
                'Digite seu nome',
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
                'Digite sua cidade',
                controller: _cidadeController,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe sua cidade.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              Input(
                'Sobre mim',
                'Conte um pouco sobre você',
                controller: _sobreMimController,
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              Botoes(
                _carregando ? 'Salvando...' : 'Salvar alterações',
                onPressed: _carregando ? null : _salvarAlteracoes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
