import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/usuario.dart';

class UsuarioControl {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Usuario?> buscarUsuarioAtual() async {
    final usuarioAtual = _auth.currentUser;

    if (usuarioAtual == null) {
      return null;
    }

    final documento = await _firestore
        .collection('usuarios')
        .doc(usuarioAtual.uid)
        .get();

    if (!documento.exists) {
      return null;
    }

    final dados = documento.data();

    if (dados == null) {
      return null;
    }

    return Usuario.fromMap(dados);
  }

  Future<void> criarPerfilSeAusente({
    required String nome,
    required String cidade,
  }) async {
    final usuarioAtual = _auth.currentUser;

    if (usuarioAtual == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    final nomeLimpo = nome.trim();
    final cidadeLimpa = cidade.trim();
    final email = usuarioAtual.email?.trim();

    if (nomeLimpo.isEmpty || cidadeLimpa.isEmpty) {
      throw ArgumentError('Nome e cidade são obrigatórios.');
    }

    if (email == null || email.isEmpty) {
      throw StateError('A conta não possui um e-mail válido.');
    }

    final usuario = Usuario(
      uid: usuarioAtual.uid,
      nome: nomeLimpo,
      email: email,
      cidade: cidadeLimpa,
    );

    final referencia = _firestore
        .collection('usuarios')
        .doc(usuarioAtual.uid);

    await _firestore.runTransaction((transacao) async {
      final documento = await transacao.get(referencia);

      if (documento.exists) {
        return;
      }

      transacao.set(referencia, usuario.toMap());
    });
  }

  Future<void> atualizarUsuario({
    required String nome,
    required String cidade,
    required String sobreMim,
  }) async {
    final usuarioAtual = _auth.currentUser;

    if (usuarioAtual == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    await _firestore
        .collection('usuarios')
        .doc(usuarioAtual.uid)
        .update({
      'nome': nome.trim(),
      'cidade': cidade.trim(),
      'sobreMim': sobreMim.trim(),
    });
  }
}
