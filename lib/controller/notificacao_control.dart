import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/notificacao.dart';

class NotificacaoControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _obterUidUsuarioAtual() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  CollectionReference<Map<String, dynamic>>
  _colecaoNotificacoes(String usuarioId) {
    return _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('notificacoes');
  }

  void adicionarNaTransacao({
    required Transaction transacao,
    required String tipo,
    required String titulo,
    required String mensagem,
    required String remetenteId,
    required String remetenteNome,
    required String destinatarioId,
    required String eventoId,
    required String publicacaoId,
    String? conversaId,
    String? doacaoId,
  }) {
    final remetente = remetenteId.trim();
    final destinatario = destinatarioId.trim();
    final nome = remetenteNome.trim();
    final tituloLimpo = titulo.trim();
    final mensagemLimpa = mensagem.trim();

    if (nome.isEmpty ||
        tituloLimpo.isEmpty ||
        mensagemLimpa.isEmpty) {
      throw ArgumentError('Dados da notificação inválidos.');
    }

    if (mensagemLimpa.length > 300) {
      throw ArgumentError(
        'A mensagem da notificação excede o limite permitido.',
      );
    }

    if (remetente.isEmpty ||
        destinatario.isEmpty ||
        remetente == destinatario) {
      throw ArgumentError('Participantes da notificação inválidos.');
    }

    if (eventoId.trim().isEmpty || publicacaoId.trim().isEmpty) {
      throw ArgumentError('Identificadores da notificação inválidos.');
    }

    const tiposPermitidos = {
      'novo_interesse',
      'interessado_escolhido',
      'doacao_concluida',
      'doacao_reaberta',
      'nova_mensagem',
    };

    if (!tiposPermitidos.contains(tipo)) {
      throw ArgumentError('Tipo de notificação inválido.');
    }

    final notificacaoRef = _colecaoNotificacoes(destinatario).doc();

    transacao.set(notificacaoRef, {
      'tipo': tipo,
      'titulo': tituloLimpo,
      'mensagem': mensagemLimpa,
      'remetenteId': remetente,
      'remetenteNome': nome,
      'destinatarioId': destinatario,
      'eventoId': eventoId.trim(),
      'publicacaoId': publicacaoId.trim(),
      'conversaId': conversaId,
      'doacaoId': doacaoId,
      'lida': false,
      'dataCriacao': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Notificacao>> acompanharNotificacoes() {
    final usuarioId = _auth.currentUser?.uid;

    if (usuarioId == null) {
      return Stream<List<Notificacao>>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _colecaoNotificacoes(usuarioId)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((resultado) {
      return resultado.docs.map((documento) {
        return Notificacao.fromMap(
          documento.data(),
          documento.id,
        );
      }).toList();
    });
  }

  Stream<int> acompanharQuantidadeNaoLidas() {
    final usuarioId = _auth.currentUser?.uid;

    if (usuarioId == null) {
      return Stream<int>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _colecaoNotificacoes(usuarioId)
        .where('lida', isEqualTo: false)
        .snapshots()
        .map((resultado) => resultado.size);
  }

  Future<void> marcarComoLida(String notificacaoId) async {
    final usuarioId = _obterUidUsuarioAtual();
    final id = notificacaoId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Identificador da notificação inválido.');
    }

    await _colecaoNotificacoes(usuarioId).doc(id).update({
      'lida': true,
    });
  }

  Future<void> marcarTodasComoLidas() async {
    final usuarioId = _obterUidUsuarioAtual();
    final colecao = _colecaoNotificacoes(usuarioId);

    while (true) {
      final resultado = await colecao
          .where('lida', isEqualTo: false)
          .limit(500)
          .get();

      if (resultado.docs.isEmpty) {
        return;
      }

      final lote = _firestore.batch();

      for (final documento in resultado.docs) {
        lote.update(documento.reference, {
          'lida': true,
        });
      }

      await lote.commit();
    }
  }
}