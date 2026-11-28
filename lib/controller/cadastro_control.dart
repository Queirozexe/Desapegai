import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/usuario.dart';

class CadastroControl {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? validarCadastro({
    required String nome,
    required String email,
    required String cidade,
    required String senha,
    required bool aceitouTermos,
  }) {
    if (nome.trim().isEmpty) return 'Informe seu nome completo.';
    if (email.trim().isEmpty) return 'Informe seu e-mail.';

    final emailValido = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
        .hasMatch(email.trim());

    if (!emailValido) return 'Informe um e-mail válido.';
    if (cidade.trim().isEmpty) return 'Informe sua cidade.';
    if (senha.length < 8) return 'A senha deve ter pelo menos 8 caracteres.';
    if (!aceitouTermos) return 'Você precisa aceitar os termos de uso.';

    return null;
  }

  Future<UserCredential> cadastrarUsuario({
    required String nome,
    required String email,
    required String cidade,
    required String senha,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );

    final user = credential.user;

    if (user == null) {
      throw StateError('Não foi possível obter os dados do usuário criado.');
    }

    final usuario = Usuario(
      uid: user.uid,
      nome: nome.trim(),
      email: user.email ?? email.trim(),
      cidade: cidade.trim(),
    );

    await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .set(usuario.toMap());

    return credential;
  }
}
