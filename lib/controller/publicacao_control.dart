import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/publicacao.dart';

class PublicacaoControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> cadastrarPublicacao(Publicacao publicacao) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final dados = publicacao.toMap();

    dados['usuarioId'] = usuario.uid;

    final documento = await _firestore
        .collection('publicacoes')
        .add(dados);

    return documento.id;
  }

  Future<List<Publicacao>> buscarPublicacoes() async {
    final resultado = await _firestore
        .collection('publicacoes')
        .where('status', isEqualTo: 'ativa')
        .get();

    return resultado.docs.map((documento) {
      return Publicacao.fromMap(
        documento.data(),
        documento.id,
      );
    }).toList();
  }
}
