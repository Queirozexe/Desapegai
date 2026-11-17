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
}
