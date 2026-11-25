import 'package:flutter/material.dart';

import '../controller/bloqueio_control.dart';
import '../theme/app_theme.dart';
import 'input.dart';
import 'botoes.dart';

class DialogoDenuncia extends StatefulWidget {
  final String titulo;
  final List<String> motivos;
  final String? usuarioId;
  final String? nomeUsuario;

  const DialogoDenuncia({
    super.key,
    required this.titulo,
    required this.motivos,
    this.usuarioId,
    this.nomeUsuario,
  });

  static Future<Map<String, String>?> mostrar({
    required BuildContext context,
    required String titulo,
    required List<String> motivos,
    String? usuarioId,
    String? nomeUsuario,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => DialogoDenuncia(
        titulo: titulo,
        motivos: motivos,
        usuarioId: usuarioId,
        nomeUsuario: nomeUsuario,
      ),
    );
  }

  @override
  State<DialogoDenuncia> createState() => _DialogoDenunciaState();
}

class _DialogoDenunciaState extends State<DialogoDenuncia> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _descricaoController = TextEditingController();
  final BloqueioControl _bloqueioControl = BloqueioControl();

  late final Stream<bool>? _bloqueioStream;

  bool _processandoBloqueio = false;

  String? _motivoSelecionado;

  @override
  void initState() {
    super.initState();

    final usuarioId = widget.usuarioId;

    _bloqueioStream = usuarioId == null || usuarioId.isEmpty
        ? null
        : _bloqueioControl.acompanharBloqueioFeitoPorMim(
      usuarioId,
    );
  }

  Future<void> _alterarBloqueio(bool bloqueado) async {
    final usuarioId = widget.usuarioId;
    final nomeUsuario = widget.nomeUsuario;

    if (_processandoBloqueio ||
        usuarioId == null ||
        nomeUsuario == null) {
      return;
    }

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            bloqueado
                ? 'Desbloquear $nomeUsuario?'
                : 'Bloquear $nomeUsuario?',
          ),
          content: Text(
            bloqueado
                ? 'Essa pessoa poderá voltar a interagir com você.'
                : 'Vocês não poderão interagir e as publicações dessa pessoa ficarão ocultas para você.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                bloqueado ? 'Desbloquear' : 'Bloquear',
                style: TextStyle(
                  color: bloqueado ? AppColors.green : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    setState(() {
      _processandoBloqueio = true;
    });

    try {
      if (bloqueado) {
        await _bloqueioControl.desbloquearUsuario(usuarioId);
      } else {
        await _bloqueioControl.bloquearUsuario(
          usuarioId: usuarioId,
          nome: nomeUsuario,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bloqueado
                ? 'Usuário desbloqueado.'
                : 'Usuário bloqueado.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível alterar o bloqueio. Tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processandoBloqueio = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      {
        'motivo': _motivoSelecionado!,
        'descricao': _descricaoController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: AppColors.green,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.titulo,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2B24),
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ajude a manter a comunidade segura. '
                  'Informe o motivo da denúncia para que a situação '
                  'possa ser analisada.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.muted,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Motivo da denúncia',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _motivoSelecionado,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Selecione um motivo',
                border: OutlineInputBorder(),
              ),
              items: widget.motivos.map((motivo) {
                return DropdownMenuItem<String>(
                  value: motivo,
                  child: Text(
                    motivo,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _motivoSelecionado = valor;
                });
              },
              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Selecione um motivo.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            const Text(
              'Detalhes (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Input(
              '',
              'Conte o que aconteceu para ajudar a nossa análise',
              controller: _descricaoController,
              semRotulo: true,
              maxLines: 3,
              maxLength: 500,
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.green,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Sua denúncia será registrada de forma '
                          'privada e poderá ser analisada pela equipe '
                          'responsável.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF34443C),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Botoes(
              'Enviar denúncia',
              onPressed: _confirmar,
            ),

            if (_bloqueioStream != null)
              StreamBuilder<bool>(
                stream: _bloqueioStream,
                builder: (context, snapshot) {
                  final bloqueado = snapshot.data ?? false;

                  return TextButton.icon(
                    onPressed: _processandoBloqueio
                        ? null
                        : () => _alterarBloqueio(bloqueado),
                    icon: Icon(
                      bloqueado
                          ? Icons.lock_open_outlined
                          : Icons.block,
                    ),
                    label: Text(
                      _processandoBloqueio
                          ? 'Processando...'
                          : bloqueado
                          ? 'Desbloquear usuário'
                          : 'Bloquear usuário',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor:
                      bloqueado ? AppColors.green : Colors.red,
                    ),
                  );
                },
              ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
