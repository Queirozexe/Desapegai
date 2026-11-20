import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InteresseControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _colecaoInteresses(
      String publicacaoId,
      ) {
    return _firestore
        .collection('publicacoes')
        .doc(publicacaoId)
        .collection('interesses');
  }

  String _validarPublicacaoId(String publicacaoId) {
    final id = publicacaoId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID da publicação inválido.');
    }

    return id;
  }

  String _obterUidUsuarioAtual() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  Future<bool> usuarioTemInteresse(String publicacaoId) async {
    final id = _validarPublicacaoId(publicacaoId);
    final uid = _obterUidUsuarioAtual();

    final documento = await _colecaoInteresses(id).doc(uid).get();

    return documento.exists;
  }

  Future<void> demonstrarInteresse(String publicacaoId) async {
    final id = _validarPublicacaoId(publicacaoId);
    final uid = _obterUidUsuarioAtual();

    await _colecaoInteresses(id).doc(uid).set({
      'usuarioId': uid,
      'dataCriacao': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelarInteresse(String publicacaoId) async {
    final id = _validarPublicacaoId(publicacaoId);
    final uid = _obterUidUsuarioAtual();

    await _colecaoInteresses(id).doc(uid).delete();
  }
}