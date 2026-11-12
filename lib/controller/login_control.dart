class LoginControl {
  final String emailTeste = 'usuario@desapegai.com';
  final String senhaTeste = '12345678';

  bool validarLogin(String email, String senha) {
    return email.trim().toLowerCase() == emailTeste &&
        senha == senhaTeste;
  }
}
