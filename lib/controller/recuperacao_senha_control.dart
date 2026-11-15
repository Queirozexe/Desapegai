import 'package:firebase_auth/firebase_auth.dart';

class RecuperacaoSenhaControl {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? validarEmail(String email) {
    final emailFormatado = email.trim();

    if (emailFormatado.isEmpty) {
      return 'Informe o e-mail cadastrado.';
    }

    final emailValido = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(emailFormatado);

    if (!emailValido) {
      return 'Informe um e-mail válido.';
    }

    return null;
  }

  Future<void> enviarEmailRecuperacao({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }
}
