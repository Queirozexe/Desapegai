
import 'package:flutter/material.dart';

class Botoes extends StatelessWidget {
  final String texto;
  final void Function()? onPressed;

  const Botoes(
      this.texto, {
        super.key,
        required this.onPressed,
      });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(texto),
    );
  }
}
