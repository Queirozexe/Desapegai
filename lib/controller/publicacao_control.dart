
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

    final documentoUsuario = await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

    final dadosUsuario = documentoUsuario.data();
    final nomeDoador = dadosUsuario?['nome'];

    if (nomeDoador is! String || nomeDoador.trim().isEmpty) {
      throw Exception(
        'Não foi possível localizar o nome do doador no perfil.',
      );
    }

    final dados = publicacao.toMap();

    dados['usuarioId'] = usuario.uid;
    dados['nomeDoador'] = nomeDoador.trim();

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

  Stream<List<Publicacao>> acompanharPublicacoes() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return Stream<List<Publicacao>>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _firestore
        .collection('publicacoes')
        .where('status', isEqualTo: 'ativa')
        .where('usuarioId', isNotEqualTo: usuario.uid)
        .snapshots()
        .map((resultado) {
      final publicacoes = resultado.docs.map((documento) {
        return Publicacao.fromMap(
          documento.data(),
          documento.id,
        );
      }).toList();

      publicacoes.sort(
            (a, b) => b.dataCriacao.compareTo(a.dataCriacao),
      );

      return publicacoes;
    });
  }
}
