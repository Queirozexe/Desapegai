
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
          style: const TextStyle(
            color: Colors.black,
            backgroundColor: Colors.white70,
          ),
          decoration: InputDecoration(
            labelText: labelExterno ? null : rotulo,
            hintText: label,
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
            ),
          ),
        ),
      ],
    );
  }
}
