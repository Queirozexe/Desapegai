import 'package:flutter/material.dart';
class Textos extends StatelessWidget {
  String meuTexto;
  Color cores;
  Textos(this.meuTexto, this.cores);

  @override
  Widget build(BuildContext context) {
    return  Text(
      this.meuTexto,
      style: TextStyle(
          color: this.cores,

          fontSize: 35
      ),
    );
  }
}
