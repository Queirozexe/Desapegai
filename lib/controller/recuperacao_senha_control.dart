class RecuperacaoSenhaControl {
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
}
