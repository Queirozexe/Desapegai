import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/publicacao.dart';
import 'chat_control.dart';
import 'notificacao_control.dart';

class PublicacaoControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificacaoControl _notificacaoControl = NotificacaoControl();

  Future<String> cadastrarPublicacao(Publicacao publicacao) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final documentoUsuario =
        await _firestore.collection('usuarios').doc(usuario.uid).get();

    final dadosUsuario = documentoUsuario.data();
    final nomeDoador = dadosUsuario?['nome'];

    if (nomeDoador is! String || nomeDoador.trim().isEmpty) {
      throw Exception('Não foi possível localizar o nome do doador no perfil.');
    }

    final dados = publicacao.toMap();

    dados['usuarioId'] = usuario.uid;
    dados['nomeDoador'] = nomeDoador.trim();

    final documento = await _firestore.collection('publicacoes').add(dados);

    return documento.id;
  }

  Future<Publicacao> buscarPublicacaoPorId(String publicacaoId) async {
    if (_auth.currentUser == null) {
      throw Exception('Usuário não autenticado.');
    }

    final id = publicacaoId.trim();

    if (id.isEmpty) {
      throw Exception('Identificador da publicação inválido.');
    }

    final documento = await _firestore.collection('publicacoes').doc(id).get();

    final dados = documento.data();

    if (!documento.exists || dados == null) {
      throw Exception('Publicação não encontrada.');
    }

    return Publicacao.fromMap(dados, documento.id);
  }

  Future<List<Publicacao>> buscarPublicacoes() async {
    final resultado =
        await _firestore
            .collection('publicacoes')
            .where('status', isEqualTo: 'ativa')
            .get();

    return resultado.docs.map((documento) {
      return Publicacao.fromMap(documento.data(), documento.id);
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
          final publicacoes =
              resultado.docs.map((documento) {
                return Publicacao.fromMap(documento.data(), documento.id);
              }).toList();

          publicacoes.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));

          return publicacoes;
        });
  }

  Stream<List<Publicacao>> acompanharMinhasPublicacoes() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return Stream<List<Publicacao>>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _firestore
        .collection('publicacoes')
        .where('usuarioId', isEqualTo: usuario.uid)
        .snapshots()
        .map((resultado) {
          final publicacoes =
              resultado.docs.map((documento) {
                return Publicacao.fromMap(documento.data(), documento.id);
              }).toList();

          publicacoes.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));

          return publicacoes;
        });
  }

  Future<void> atualizarPublicacao({
    required String publicacaoId,
    required String titulo,
    required String descricao,
    required String categoria,
    required String estadoConservacao,
    required String cidade,
    required List<String> imagens,
    required GeoPoint? coordenadas,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final id = publicacaoId.trim();

    if (id.isEmpty) {
      throw Exception('Identificador da publicação inválido.');
    }

    if (imagens.isEmpty || imagens.length > 3) {
      throw Exception('A publicação deve possuir entre 1 e 3 imagens.');
    }

    final publicacaoRef = _firestore.collection('publicacoes').doc(id);

    await _firestore.runTransaction((transacao) async {
      final documento = await transacao.get(publicacaoRef);

      if (!documento.exists) {
        throw Exception('Publicação não encontrada.');
      }

      final dados = documento.data()!;

      if (dados['usuarioId'] != usuario.uid) {
        throw Exception('Você não é o dono desta publicação.');
      }

      final atualizacao = <String, dynamic>{
        'titulo': titulo.trim(),
        'descricao': descricao.trim(),
        'categoria': categoria,
        'estadoConservacao': estadoConservacao,
        'cidade': cidade.trim(),
        'imagens': imagens,
      };

      if (coordenadas != null) {
        atualizacao['coordenadas'] = coordenadas;
      } else {
        atualizacao['coordenadas'] = FieldValue.delete();
      }

      transacao.update(publicacaoRef, atualizacao);
    });

    await ChatControl().atualizarDadosPublicacaoNasConversas(
      publicacaoId: id,
      tituloPublicacao: titulo.trim(),
      imagens: imagens,
    );
  }

  Future<void> removerPublicacao({required String publicacaoId}) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final id = publicacaoId.trim();

    if (id.isEmpty) {
      throw Exception('Identificador da publicação inválido.');
    }

    final publicacaoRef = _firestore.collection('publicacoes').doc(id);

    final documento = await publicacaoRef.get();

    if (!documento.exists) {
      throw Exception('Publicação não encontrada.');
    }

    final dados = documento.data()!;

    if (dados['usuarioId'] != usuario.uid) {
      throw Exception('Você não é o dono desta publicação.');
    }

    await ChatControl().removerConversasDaPublicacao(publicacaoId: id);

    final interesses = await publicacaoRef.collection('interesses').get();

    for (var i = 0; i < interesses.docs.length; i += 500) {
      final lote = _firestore.batch();

      final fim =
          (i + 500 < interesses.docs.length) ? i + 500 : interesses.docs.length;

      for (final interesse in interesses.docs.sublist(i, fim)) {
        lote.delete(interesse.reference);
      }

      await lote.commit();
    }

    await publicacaoRef.delete();
  }

  Future<void> escolherInteressado({
    required String publicacaoId,
    required String usuarioEscolhidoId,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final idPublicacao = publicacaoId.trim();
    final idUsuarioEscolhido = usuarioEscolhidoId.trim();

    if (idPublicacao.isEmpty || idUsuarioEscolhido.isEmpty) {
      throw Exception('Identificadores inválidos.');
    }

    if (idUsuarioEscolhido == usuario.uid) {
      throw Exception('Você não pode escolher a si mesmo.');
    }

    final publicacaoRef = _firestore
        .collection('publicacoes')
        .doc(idPublicacao);

    final interesseRef = publicacaoRef
        .collection('interesses')
        .doc(idUsuarioEscolhido);

    await _firestore.runTransaction((transacao) async {
      final documentoPublicacao = await transacao.get(publicacaoRef);

      if (!documentoPublicacao.exists) {
        throw Exception('Publicação não encontrada.');
      }

      final dadosPublicacao = documentoPublicacao.data()!;

      if (dadosPublicacao['usuarioId'] != usuario.uid) {
        throw Exception('Você não é o dono desta publicação.');
      }

      if (dadosPublicacao['status'] != 'ativa') {
        throw Exception('Esta publicação não está disponível.');
      }

      if (dadosPublicacao.containsKey('usuarioEscolhidoId')) {
        throw Exception('Já existe uma pessoa escolhida.');
      }

      final documentoInteresse = await transacao.get(interesseRef);

      if (!documentoInteresse.exists) {
        throw Exception('Esta pessoa não demonstrou interesse.');
      }

      final dadosInteresse = documentoInteresse.data()!;

      if (dadosInteresse['usuarioId'] != idUsuarioEscolhido) {
        throw Exception('Registro de interesse inválido.');
      }

      final nomeBeneficiario = dadosInteresse['nomeUsuario'];
      final cidadeBeneficiario = dadosInteresse['cidade'];
      final tituloPublicacao = dadosPublicacao['titulo'];
      final nomeDoador = dadosPublicacao['nomeDoador'];

      if (nomeBeneficiario is! String ||
          nomeBeneficiario.trim().isEmpty) {
        throw Exception('Nome do beneficiário inválido.');
      }

      if (cidadeBeneficiario is! String ||
          cidadeBeneficiario.trim().isEmpty) {
        throw Exception('Cidade do beneficiário inválida.');
      }

      if (tituloPublicacao is! String ||
          tituloPublicacao.trim().isEmpty) {
        throw Exception('Título da publicação inválido.');
      }

      if (nomeDoador is! String || nomeDoador.trim().isEmpty) {
        throw Exception('Nome do doador inválido.');
      }

      transacao.update(publicacaoRef, {
        'status': 'em_andamento',
        'usuarioEscolhidoId': idUsuarioEscolhido,
        'usuarioEscolhidoNome': nomeBeneficiario.trim(),
        'usuarioEscolhidoCidade': cidadeBeneficiario.trim(),
      });

      _notificacaoControl.adicionarNaTransacao(
        transacao: transacao,
        tipo: 'interessado_escolhido',
        titulo: 'Você foi escolhido!',
        mensagem:
        '${nomeDoador.trim()} escolheu você para receber '
            '"${tituloPublicacao.trim()}".',
        remetenteId: usuario.uid,
        remetenteNome: nomeDoador.trim(),
        destinatarioId: idUsuarioEscolhido,
        eventoId: idPublicacao,
        publicacaoId: idPublicacao,
      );
    });
  }

  Future<void> desfazerEscolha({
    required String publicacaoId,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

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

      if (dados['usuarioId'] != usuario.uid) {
        throw Exception('Você não é o dono desta publicação.');
      }

      if (dados['status'] != 'em_andamento' ||
          dados['usuarioEscolhidoId'] is! String) {
        throw Exception('Não existe uma escolha para desfazer.');
      }

      transacao.update(publicacaoRef, {
        'status': 'ativa',
        'usuarioEscolhidoId': FieldValue.delete(),
        'usuarioEscolhidoNome': FieldValue.delete(),
        'usuarioEscolhidoCidade': FieldValue.delete(),
      });
    });
  }
}