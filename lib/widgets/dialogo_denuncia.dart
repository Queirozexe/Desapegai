
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'input.dart';
import 'botoes.dart';

class DialogoDenuncia extends StatefulWidget {
  final String titulo;
  final List<String> motivos;

  const DialogoDenuncia({
    super.key,
    required this.titulo,
    required this.motivos,
  });

  static Future<Map<String, String>?> mostrar({
    required BuildContext context,
    required String titulo,
    required List<String> motivos,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => DialogoDenuncia(
        titulo: titulo,
        motivos: motivos,
      ),
    );
  }

  @override
  State<DialogoDenuncia> createState() => _DialogoDenunciaState();
}

class _DialogoDenunciaState extends State<DialogoDenuncia> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _descricaoController =
  TextEditingController();

  String? _motivoSelecionado;

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
