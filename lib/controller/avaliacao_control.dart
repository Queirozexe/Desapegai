import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/avaliacao.dart';

class AvaliacaoControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _firestore.collection('avaliacoes');

  String _obterUidUsuarioAtual() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  String _gerarIdAvaliacao(String doacaoId, String avaliadorId) {
    return '${doacaoId}_$avaliadorId';
  }

  Stream<Avaliacao?> acompanharAvaliacaoDaDoacao(String doacaoId) {
    final uid = _obterUidUsuarioAtual();
    final id = doacaoId.trim();

    if (id.isEmpty) {
      return Stream.error(
        ArgumentError('Identificador da doação inválido.'),
      );
    }

    return _colecao
        .doc(_gerarIdAvaliacao(id, uid))
        .snapshots()
        .map((documento) {
      if (!documento.exists) {
        return null;
      }

      return Avaliacao.fromMap(documento.data()!, documento.id);
    });
  }

  Stream<ResumoAvaliacoes> acompanharResumoAvaliacoes(
      String avaliadoId,
      ) {
    final uid = avaliadoId.trim();

    if (uid.isEmpty) {
      return Stream.error(
        ArgumentError('Identificador do usuário inválido.'),
      );
    }

    return _colecao
        .where('avaliadoId', isEqualTo: uid)
        .snapshots()
        .map((resultado) {

      final notas = resultado.docs
          .map((documento) => documento.data()['nota'] as num)
          .toList();

      final quantidade = notas.length;

      final media = quantidade == 0
          ? 0.0
          : notas.fold<double>(
        0,
            (total, nota) => total + nota.toDouble(),
      ) /
          quantidade;

      return ResumoAvaliacoes(
        media: media,
        quantidade: quantidade,
      );
    });
  }

  Future<void> avaliarDoacao({
    required String doacaoId,
    required int nota,
    String comentario = '',
  }) async {
    final uid = _obterUidUsuarioAtual();
    final id = doacaoId.trim();
    final comentarioLimpo = comentario.trim();

    if (id.isEmpty) {
      throw ArgumentError('Identificador da doação inválido.');
    }

    if (nota < 1 || nota > 5) {
      throw ArgumentError('A nota deve estar entre 1 e 5.');
    }

    if (comentarioLimpo.length > 500) {
      throw ArgumentError(
        'O comentário deve possuir no máximo 500 caracteres.',
      );
    }

    final doacaoRef = _firestore.collection('doacoes').doc(id);
    final avaliacaoRef = _colecao.doc(_gerarIdAvaliacao(id, uid));

    await _firestore.runTransaction((transacao) async {
      final documentoDoacao = await transacao.get(doacaoRef);
      final documentoAvaliacao = await transacao.get(avaliacaoRef);

      if (!documentoDoacao.exists) {
        throw Exception('Doação não encontrada.');
      }

      if (documentoAvaliacao.exists) {
        throw Exception('Você já avaliou esta doação.');
      }

      final dados = documentoDoacao.data()!;

      if (dados['status'] != 'concluida') {
        throw Exception(
          'Somente doações concluídas podem ser avaliadas.',
        );
      }

      final doadorId = dados['doadorId'];
      final beneficiarioId = dados['beneficiarioId'];
      final publicacaoId = dados['publicacaoId'];

      if (doadorId is! String ||
          beneficiarioId is! String ||
          publicacaoId is! String ||
          doadorId == beneficiarioId) {
        throw Exception('Dados dos participantes inválidos.');
      }

      final participantes = List<String>.from(
        dados['participantes'] ?? [],
      );

      if (!participantes.contains(uid) ||
          !participantes.contains(doadorId) ||
          !participantes.contains(beneficiarioId)) {
        throw Exception(
          'Você não participa desta doação.',
        );
      }

      final avaliadoId = uid == doadorId
          ? beneficiarioId
          : uid == beneficiarioId
          ? doadorId
          : null;

      if (avaliadoId == null) {
        throw Exception('Não foi possível identificar o participante.');
      }

      transacao.set(avaliacaoRef, {
        'doacaoId': id,
        'publicacaoId': publicacaoId,
        'avaliadorId': uid,
        'avaliadoId': avaliadoId,
        'nota': nota,
        'comentario': comentarioLimpo,
        'dataCriacao': FieldValue.serverTimestamp(),
      });
    });
  }
}
