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

  Future<void> atualizarPublicacao({
    required String publicacaoId,
    required String titulo,
    required String descricao,
    required String categoria,
    required String estadoConservacao,
    required String cidade,
    required List<String> imagens,
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

    final publicacaoRef = _firestore
        .collection('publicacoes')
        .doc(id);

    await _firestore.runTransaction((transacao) async {
      final documento = await transacao.get(publicacaoRef);

      if (!documento.exists) {
        throw Exception('Publicação não encontrada.');
      }

      final dados = documento.data()!;

      if (dados['usuarioId'] != usuario.uid) {
        throw Exception('Você não é o dono desta publicação.');
      }

      transacao.update(publicacaoRef, {
        'titulo': titulo.trim(),
        'descricao': descricao.trim(),
        'categoria': categoria,
        'estadoConservacao': estadoConservacao,
        'cidade': cidade.trim(),
        'imagens': imagens,
      });
    });
  }

  Future<void> removerPublicacao({
    required String publicacaoId,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final id = publicacaoId.trim();

    if (id.isEmpty) {
      throw Exception('Identificador da publicação inválido.');
    }

    final publicacaoRef = _firestore
        .collection('publicacoes')
        .doc(id);

    final documento = await publicacaoRef.get();

    if (!documento.exists) {
      throw Exception('Publicação não encontrada.');
    }

    final dados = documento.data()!;

    if (dados['usuarioId'] != usuario.uid) {
      throw Exception('Você não é o dono desta publicação.');
    }

    final interesses = await publicacaoRef
        .collection('interesses')
        .get();

    for (var i = 0; i < interesses.docs.length; i += 500) {
      final lote = _firestore.batch();

      final fim = (i + 500 < interesses.docs.length)
          ? i + 500
          : interesses.docs.length;

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
      final documentoPublicacao =
      await transacao.get(publicacaoRef);

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

      final documentoInteresse =
      await transacao.get(interesseRef);

      if (!documentoInteresse.exists) {
        throw Exception('Esta pessoa não demonstrou interesse.');
      }

      final dadosInteresse = documentoInteresse.data()!;

      if (dadosInteresse['usuarioId'] != idUsuarioEscolhido) {
        throw Exception('Registro de interesse inválido.');
      }

      transacao.update(publicacaoRef, {
        'status': 'em_andamento',
        'usuarioEscolhidoId': idUsuarioEscolhido,
      });
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
      });
    });
  }

  Future<void> concluirDoacao({
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
        throw Exception('Esta doação não pode ser concluída.');
      }

      if (dados.containsKey('dataConclusao')) {
        throw Exception(
          'Esta doação já possui uma data de conclusão.',
        );
      }

      transacao.update(publicacaoRef, {
        'status': 'concluida',
        'dataConclusao': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> reabrirDoacao({
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

      if (dados['status'] != 'concluida' ||
          dados['usuarioEscolhidoId'] is! String ||
          dados['dataConclusao'] is! Timestamp) {
        throw Exception('Esta doação não pode ser reaberta.');
      }

      transacao.update(publicacaoRef, {
        'status': 'ativa',
        'usuarioEscolhidoId': FieldValue.delete(),
        'dataConclusao': FieldValue.delete(),
      });
    });
  }
}
