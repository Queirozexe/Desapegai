import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/interessado.dart';
import 'notificacao_control.dart';

class InteresseControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificacaoControl _notificacaoControl = NotificacaoControl();

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

  Future<void> demonstrarInteresse(
      String publicacaoId, {
        required String mensagem,
      }) async {
    final id = _validarPublicacaoId(publicacaoId);
    final uid = _obterUidUsuarioAtual();
    final texto = mensagem.trim();

    if (texto.isEmpty) {
      throw ArgumentError('A mensagem não pode ficar vazia.');
    }

    if (texto.length > 250) {
      throw ArgumentError(
        'A mensagem deve ter no máximo 250 caracteres.',
      );
    }

    final perfil = await _firestore
        .collection('usuarios')
        .doc(uid)
        .get();

    if (!perfil.exists) {
      throw StateError('Perfil do usuário não encontrado.');
    }

    final dadosPerfil = perfil.data();
    final nome = dadosPerfil?['nome'];
    final cidade = dadosPerfil?['cidade'];

    if (nome is! String || nome.trim().isEmpty) {
      throw StateError('Nome do usuário não encontrado no perfil.');
    }

    if (cidade is! String || cidade.trim().isEmpty) {
      throw StateError('Cidade do usuário não encontrada no perfil.');
    }

    final publicacaoRef = _firestore
        .collection('publicacoes')
        .doc(id);

    final interesseRef = _colecaoInteresses(id).doc(uid);

    await _firestore.runTransaction((transacao) async {
      final documentoPublicacao = await transacao.get(publicacaoRef);
      final documentoInteresse = await transacao.get(interesseRef);

      if (!documentoPublicacao.exists) {
        throw Exception('Publicação não encontrada.');
      }

      final dadosPublicacao = documentoPublicacao.data()!;

      if (dadosPublicacao['status'] != 'ativa') {
        throw Exception('Esta publicação não está disponível.');
      }

      final doadorId = dadosPublicacao['usuarioId'];
      final tituloPublicacao = dadosPublicacao['titulo'];

      if (doadorId is! String ||
          doadorId.trim().isEmpty ||
          doadorId == uid) {
        throw Exception('Doador da publicação inválido.');
      }

      if (tituloPublicacao is! String ||
          tituloPublicacao.trim().isEmpty) {
        throw Exception('Título da publicação inválido.');
      }

      if (documentoInteresse.exists) {
        throw Exception('Você já demonstrou interesse nesta publicação.');
      }

      transacao.set(interesseRef, {
        'usuarioId': uid,
        'nomeUsuario': nome.trim(),
        'cidade': cidade.trim(),
        'mensagem': texto,
        'dataCriacao': FieldValue.serverTimestamp(),
      });

      _notificacaoControl.adicionarNaTransacao(
        transacao: transacao,
        tipo: 'novo_interesse',
        titulo: 'Novo interesse',
        mensagem:
        '${nome.trim()} demonstrou interesse na sua publicação '
            '"${tituloPublicacao.trim()}".',
        remetenteId: uid,
        remetenteNome: nome.trim(),
        destinatarioId: doadorId,
        eventoId: uid,
        publicacaoId: id,
      );
    });
  }

  Future<void> cancelarInteresse(String publicacaoId) async {
    final id = _validarPublicacaoId(publicacaoId);
    final uid = _obterUidUsuarioAtual();

    await _colecaoInteresses(id).doc(uid).delete();
  }

  Stream<int> acompanharQuantidadeInteresses(String publicacaoId) {
    final id = _validarPublicacaoId(publicacaoId);

    if (_auth.currentUser == null) {
      return Stream<int>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _colecaoInteresses(id)
        .snapshots()
        .map((resultado) => resultado.size);
  }

  Stream<List<Interessado>> acompanharInteressados(
      String publicacaoId,
      ) {
    final id = _validarPublicacaoId(publicacaoId);

    if (_auth.currentUser == null) {
      return Stream<List<Interessado>>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _colecaoInteresses(id)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((resultado) {
      return resultado.docs
          .map((documento) => Interessado.fromMap(documento.data()))
          .toList();
    });
  }
}
