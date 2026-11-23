import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String rotulo;
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool labelExterno;
  final bool expands;
  final int? maxLength;
  final bool semRotulo;
  final bool mostrarContador;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const Input(
      this.rotulo,
      this.label, {
        super.key,
        required this.controller,
        this.validator,
        this.maxLines = 1,
        this.keyboardType,
        this.labelExterno = false,
        this.expands = false,
        this.maxLength,
        this.semRotulo = false,
        this.mostrarContador = true,
        this.textInputAction,
        this.onFieldSubmitted,
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelExterno) ...[
          Text(
            rotulo,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          expands: expands,
          maxLength: maxLength,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: labelExterno || semRotulo ? null : rotulo,
            hintText: label,
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
            ),
            counterText: mostrarContador ? null : '',
          ),
        ),
      ],
    );
  }
}