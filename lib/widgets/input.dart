import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String rotulo;
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  const Input(
      this.rotulo,
      this.label, {
        super.key,
        required this.controller,
        this.validator,
        this.maxLines = 1,
        this.keyboardType,
      });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.black,
        backgroundColor: Colors.white70,
      ),
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: label,
      ),
    );
  }
}
