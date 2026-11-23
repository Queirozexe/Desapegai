import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/doacao.dart';

class DoacaoControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _obterUidUsuarioAtual() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  Future<void> concluirDoacao({required String publicacaoId}) async {
    final uid = _obterUidUsuarioAtual();
    final idPublicacao = publicacaoId.trim();

    if (idPublicacao.isEmpty) {
      throw Exception('Identificador da publicação inválido.');
    }

    final publicacaoRef = _firestore
        .collection('publicacoes')
        .doc(idPublicacao);

    final doacaoRef = _firestore.collection('doacoes').doc();

    await _firestore.runTransaction((transacao) async {
      final documento = await transacao.get(publicacaoRef);

      if (!documento.exists) {
        throw Exception('Publicação não encontrada.');
      }

      final dados = documento.data()!;

      if (dados['usuarioId'] != uid) {
        throw Exception('Você não é o dono desta publicação.');
      }

      if (dados['status'] != 'em_andamento' ||
          dados['usuarioEscolhidoId'] is! String) {
        throw Exception('Esta doação não pode ser concluída.');
      }

      if (dados.containsKey('dataConclusao') ||
          dados.containsKey('doacaoAtualId')) {
        throw Exception('Esta doação já possui um registro.');
      }

      final doadorNome = dados['nomeDoador'];
      final beneficiarioId = dados['usuarioEscolhidoId'];
      final beneficiarioNome = dados['usuarioEscolhidoNome'];
      final beneficiarioCidade = dados['usuarioEscolhidoCidade'];
      final titulo = dados['titulo'];
      final imagens = dados['imagens'];

      if (doadorNome is! String || doadorNome.trim().isEmpty) {
        throw Exception('Nome do doador inválido.');
      }

      if (beneficiarioId.toString().trim().isEmpty || beneficiarioId == uid) {
        throw Exception('Beneficiário inválido.');
      }

      if (beneficiarioNome is! String || beneficiarioNome.trim().isEmpty) {
        throw Exception('Nome do beneficiário inválido.');
      }

      if (beneficiarioCidade is! String || beneficiarioCidade.trim().isEmpty) {
        throw Exception('Cidade do beneficiário inválida.');
      }

      if (titulo is! String || titulo.trim().isEmpty) {
        throw Exception('Título da publicação inválido.');
      }

      String? imagemPublicacao;

      if (imagens is List &&
          imagens.isNotEmpty &&
          imagens.first is String &&
          (imagens.first as String).trim().isNotEmpty) {
        imagemPublicacao = imagens.first as String;
      }

      transacao.set(doacaoRef, {
        'publicacaoId': idPublicacao,
        'tituloPublicacao': titulo.trim(),
        'imagemPublicacao': imagemPublicacao,
        'doadorId': uid,
        'doadorNome': doadorNome.trim(),
        'beneficiarioId': beneficiarioId,
        'beneficiarioNome': beneficiarioNome.trim(),
        'beneficiarioCidade': beneficiarioCidade.trim(),
        'participantes': [uid, beneficiarioId],
        'dataConclusao': FieldValue.serverTimestamp(),
        'status': 'concluida',
      });

      transacao.update(publicacaoRef, {
        'status': 'concluida',
        'dataConclusao': FieldValue.serverTimestamp(),
        'doacaoAtualId': doacaoRef.id,
      });
    });
  }

  Future<void> reabrirDoacao({required String publicacaoId}) async {
    final uid = _obterUidUsuarioAtual();
    final idPublicacao = publicacaoId.trim();

    if (idPublicacao.isEmpty) {
      throw Exception('Identificador da publicação inválido.');
    }

    final publicacaoRef = _firestore
        .collection('publicacoes')
        .doc(idPublicacao);

    await _firestore.runTransaction((transacao) async {
      final documento = await transacao.get(publicacaoRef);

      if (!documento.exists) {
        throw Exception('Publicação não encontrada.');
      }

      final dados = documento.data()!;

      if (dados['usuarioId'] != uid) {
        throw Exception('Você não é o dono desta publicação.');
      }

      if (dados['status'] != 'concluida' ||
          dados['usuarioEscolhidoId'] is! String ||
          dados['dataConclusao'] is! Timestamp) {
        throw Exception('Esta doação não pode ser reaberta.');
      }

      final doacaoAtualId = dados['doacaoAtualId'];

      DocumentReference<Map<String, dynamic>>? doacaoRef;

      if (doacaoAtualId != null) {
        if (doacaoAtualId is! String || doacaoAtualId.trim().isEmpty) {
          throw Exception('Identificador do histórico inválido.');
        }

        doacaoRef = _firestore.collection('doacoes').doc(doacaoAtualId);

        final documentoDoacao = await transacao.get(doacaoRef);

        if (!documentoDoacao.exists) {
          throw Exception('Registro da doação não encontrado.');
        }

        final dadosDoacao = documentoDoacao.data()!;

        if (dadosDoacao['publicacaoId'] != idPublicacao ||
            dadosDoacao['doadorId'] != uid ||
            dadosDoacao['beneficiarioId'] != dados['usuarioEscolhidoId'] ||
            dadosDoacao['status'] != 'concluida') {
          throw Exception('Registro do histórico inválido.');
        }

        transacao.update(doacaoRef, {
          'status': 'reaberta',
          'dataReabertura': FieldValue.serverTimestamp(),
        });
      }

      transacao.update(publicacaoRef, {
        'status': 'ativa',
        'usuarioEscolhidoId': FieldValue.delete(),
        'usuarioEscolhidoNome': FieldValue.delete(),
        'usuarioEscolhidoCidade': FieldValue.delete(),
        'dataConclusao': FieldValue.delete(),
        'doacaoAtualId': FieldValue.delete(),
      });
    });
  }

  Stream<List<Doacao>> acompanharDoacoesFeitas() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return Stream<List<Doacao>>.error(Exception('Usuário não autenticado.'));
    }

    return _firestore
        .collection('doacoes')
        .where('participantes', arrayContains: usuario.uid)
        .snapshots()
        .map((resultado) {
          final doacoes =
              resultado.docs
                  .map(
                    (documento) =>
                        Doacao.fromMap(documento.data(), documento.id),
                  )
                  .where((doacao) => doacao.doadorId == usuario.uid)
                  .toList();

          doacoes.sort((a, b) => b.dataConclusao.compareTo(a.dataConclusao));

          return doacoes;
        });
  }

  Stream<List<Doacao>> acompanharDoacoesRecebidas() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return Stream<List<Doacao>>.error(Exception('Usuário não autenticado.'));
    }

    return _firestore
        .collection('doacoes')
        .where('participantes', arrayContains: usuario.uid)
        .snapshots()
        .map((resultado) {
          final doacoes =
              resultado.docs
                  .map(
                    (documento) =>
                        Doacao.fromMap(documento.data(), documento.id),
                  )
                  .where((doacao) => doacao.beneficiarioId == usuario.uid)
                  .toList();

          doacoes.sort((a, b) => b.dataConclusao.compareTo(a.dataConclusao));

          return doacoes;
        });
  }
}
