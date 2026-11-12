class CadastroControl {
  String? validarCadastro({
    required String nome,
    required String email,
    required String cidade,
    required String senha,
    required bool aceitouTermos,
  }) {
    if (nome.trim().isEmpty) {
      return 'Informe seu nome completo.';
    }

    if (email.trim().isEmpty) {
      return 'Informe seu e-mail.';
    }

    final emailValido = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(email.trim());

    if (!emailValido) {
      return 'Informe um e-mail válido.';
    }

    if (cidade.trim().isEmpty) {
      return 'Informe sua cidade.';
    }

    if (senha.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }

    if (!aceitouTermos) {
      return 'Você precisa aceitar os termos de uso.';
    }

    return null;
  }
}
