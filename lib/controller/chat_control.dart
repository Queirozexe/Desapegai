import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/conversa.dart';
import '../model/mensagem.dart';
import 'notificacao_control.dart';

class ChatControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificacaoControl _notificacaoControl = NotificacaoControl();

  String _obterUidUsuarioAtual() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  String _validarId(String id, String nome) {
    final valor = id.trim();

    if (valor.isEmpty) {
      throw ArgumentError('$nome inválido.');
    }

    return valor;
  }

  CollectionReference<Map<String, dynamic>> _colecaoConversas() {
    return _firestore.collection('conversas');
  }

  Future<Conversa> criarOuObterConversa({
    required String publicacaoId,
    required String interessadoId,
  }) async {
    final uid = _obterUidUsuarioAtual();

    final idPublicacao = _validarId(
      publicacaoId,
      'ID da publicação',
    );

    final idInteressado = _validarId(
      interessadoId,
      'ID do interessado',
    );

    final conversaId = '${idPublicacao}_$idInteressado';

    final conversaRef = _colecaoConversas().doc(conversaId);

    final publicacaoRef = _firestore
        .collection('publicacoes')
        .doc(idPublicacao);

    final interesseRef = publicacaoRef
        .collection('interesses')
        .doc(idInteressado);

    await _firestore.runTransaction((transacao) async {
      final documentoConversa = await transacao.get(conversaRef);

      if (documentoConversa.exists) {
        final dados = documentoConversa.data()!;

        final participantes = dados['participantes'] is List
            ? List<String>.from(dados['participantes'])
            : <String>[];

        if (!participantes.contains(uid) ||
            dados['publicacaoId'] != idPublicacao ||
            dados['interessadoId'] != idInteressado) {
          throw Exception('Você não tem acesso a esta conversa.');
        }

        return;
      }

      final documentoPublicacao =
      await transacao.get(publicacaoRef);

      if (!documentoPublicacao.exists) {
        throw Exception('Publicação não encontrada.');
      }

      final documentoInteresse =
      await transacao.get(interesseRef);

      if (!documentoInteresse.exists) {
        throw Exception(
          'Não existe um registro de interesse para esta conversa.',
        );
      }

      final dadosPublicacao = documentoPublicacao.data()!;
      final dadosInteresse = documentoInteresse.data()!;

      final doadorId = dadosPublicacao['usuarioId'];
      final doadorNome = dadosPublicacao['nomeDoador'];
      final tituloPublicacao = dadosPublicacao['titulo'];
      final interessadoNome = dadosInteresse['nomeUsuario'];

      if (doadorId is! String ||
          doadorNome is! String ||
          tituloPublicacao is! String ||
          interessadoNome is! String) {
        throw Exception(
          'Não foi possível recuperar os dados da conversa.',
        );
      }

      if (doadorId == idInteressado ||
          doadorId == uid && uid == idInteressado) {
        throw Exception('Os participantes da conversa são inválidos.');
      }

      if (uid != doadorId && uid != idInteressado) {
        throw Exception(
          'Você não participa desta conversa.',
        );
      }

      if (dadosInteresse['usuarioId'] != idInteressado) {
        throw Exception('Registro de interesse inválido.');
      }

      final imagens = dadosPublicacao['imagens'];

      String? imagemPublicacao;

      if (imagens is List &&
          imagens.isNotEmpty &&
          imagens.first is String) {
        imagemPublicacao = imagens.first as String;
      }

      transacao.set(conversaRef, {
        'publicacaoId': idPublicacao,
        'tituloPublicacao': tituloPublicacao,
        'imagemPublicacao': imagemPublicacao,
        'doadorId': doadorId,
        'doadorNome': doadorNome,
        'interessadoId': idInteressado,
        'interessadoNome': interessadoNome,
        'participantes': [doadorId, idInteressado],
        'dataCriacao': FieldValue.serverTimestamp(),
        'ultimaMensagem': '',
        'ultimaMensagemRemetenteId': null,
        'dataUltimaMensagem': null,
      });
    });

    final documentoFinal = await conversaRef.get();

    if (!documentoFinal.exists) {
      throw Exception('Não foi possível criar a conversa.');
    }

    return Conversa.fromMap(
      documentoFinal.data()!,
      documentoFinal.id,
    );
  }

  Future<Conversa> buscarConversaPorId(String conversaId) async {
    final usuarioId = _obterUidUsuarioAtual();

    final id = _validarId(
      conversaId,
      'ID da conversa',
    );

    final documento = await _colecaoConversas().doc(id).get();

    if (!documento.exists) {
      throw Exception('Conversa não encontrada.');
    }

    final dados = documento.data()!;

    final participantes = dados['participantes'] is List
        ? List<String>.from(dados['participantes'])
        : <String>[];

    if (!participantes.contains(usuarioId)) {
      throw Exception('Você não participa desta conversa.');
    }

    return Conversa.fromMap(
      dados,
      documento.id,
    );
  }

  Stream<List<Conversa>> acompanharConversas() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Stream<List<Conversa>>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _colecaoConversas()
        .where('participantes', arrayContains: uid)
        .snapshots()
        .map((resultado) {
      final conversas = resultado.docs.map((documento) {
        return Conversa.fromMap(
          documento.data(),
          documento.id,
        );
      }).toList();

      conversas.sort((a, b) {
        final dataA = a.dataUltimaMensagem ??
            a.dataCriacao ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final dataB = b.dataUltimaMensagem ??
            b.dataCriacao ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return dataB.compareTo(dataA);
      });

      return conversas;
    });
  }

  Future<void> atualizarDadosPublicacaoNasConversas({
    required String publicacaoId,
    required String tituloPublicacao,
    required List<String> imagens,
  }) async {
    final uid = _obterUidUsuarioAtual();

    final id = _validarId(
      publicacaoId,
      'ID da publicação',
    );

    final titulo = tituloPublicacao.trim();

    if (titulo.isEmpty) {
      throw ArgumentError('O título da publicação é inválido.');
    }

    if (imagens.isEmpty || imagens.first.trim().isEmpty) {
      throw ArgumentError('A imagem da publicação é inválida.');
    }

    final imagemPublicacao = imagens.first;

    final resultado = await _colecaoConversas()
        .where('participantes', arrayContains: uid)
        .get();

    final conversas = resultado.docs.where((documento) {
      return documento.data()['publicacaoId'] == id;
    }).toList();

    for (final conversa in conversas) {
      final dados = conversa.data();

      if (dados['doadorId'] != uid) {
        throw Exception(
          'Você não tem permissão para atualizar esta conversa.',
        );
      }
    }

    for (var i = 0; i < conversas.length; i += 500) {
      final lote = _firestore.batch();

      final fim = (i + 500 < conversas.length)
          ? i + 500
          : conversas.length;

      for (final conversa in conversas.sublist(i, fim)) {
        final dados = conversa.data();

        if (dados['tituloPublicacao'] == titulo &&
            dados['imagemPublicacao'] == imagemPublicacao) {
          continue;
        }

        lote.update(conversa.reference, {
          'tituloPublicacao': titulo,
          'imagemPublicacao': imagemPublicacao,
        });
      }

      await lote.commit();
    }
  }

  Future<void> removerConversasDaPublicacao({
    required String publicacaoId,
  }) async {
    final uid = _obterUidUsuarioAtual();

    final id = _validarId(
      publicacaoId,
      'ID da publicação',
    );

    final resultado = await _colecaoConversas()
        .where('participantes', arrayContains: uid)
        .get();

    final conversas = resultado.docs.where((documento) {
      return documento.data()['publicacaoId'] == id;
    }).toList();

    for (final documentoConversa in conversas) {
      final dados = documentoConversa.data();

      if (dados['doadorId'] != uid) {
        throw Exception(
          'Você não tem permissão para excluir esta conversa.',
        );
      }

      final mensagensRef = documentoConversa.reference
          .collection('mensagens');

      while (true) {
        final resultadoMensagens = await mensagensRef
            .limit(500)
            .get();

        if (resultadoMensagens.docs.isEmpty) {
          break;
        }

        final lote = _firestore.batch();

        for (final mensagem in resultadoMensagens.docs) {
          lote.delete(mensagem.reference);
        }

        await lote.commit();
      }

      await documentoConversa.reference.delete();
    }
  }

  Stream<List<Mensagem>> acompanharMensagens(
      String conversaId,
      ) {
    final id = _validarId(conversaId, 'ID da conversa');

    if (_auth.currentUser == null) {
      return Stream<List<Mensagem>>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _colecaoConversas()
        .doc(id)
        .collection('mensagens')
        .orderBy('dataEnvio')
        .snapshots()
        .map((resultado) {
      return resultado.docs.map((documento) {
        return Mensagem.fromMap(
          documento.data(),
          documento.id,
        );
      }).toList();
    });
  }

  Future<void> enviarMensagem({
    required String conversaId,
    required String texto,
  }) async {
    final uid = _obterUidUsuarioAtual();

    final id = _validarId(
      conversaId,
      'ID da conversa',
    );

    final mensagemTexto = texto.trim();

    if (mensagemTexto.isEmpty) {
      throw ArgumentError('A mensagem não pode ficar vazia.');
    }

    if (mensagemTexto.length > 1000) {
      throw ArgumentError(
        'A mensagem deve ter no máximo 1000 caracteres.',
      );
    }

    final conversaRef = _colecaoConversas().doc(id);

    final mensagemRef = conversaRef
        .collection('mensagens')
        .doc();

    await _firestore.runTransaction((transacao) async {
      final documentoConversa = await transacao.get(conversaRef);

      if (!documentoConversa.exists) {
        throw Exception('Conversa não encontrada.');
      }

      final dados = documentoConversa.data()!;

      final participantes = dados['participantes'] is List
          ? List<String>.from(dados['participantes'])
          : <String>[];

      if (!participantes.contains(uid)) {
        throw Exception(
          'Você não tem permissão para enviar mensagens nesta conversa.',
        );
      }

      final doadorId = dados['doadorId'];
      final interessadoId = dados['interessadoId'];
      final doadorNome = dados['doadorNome'];
      final interessadoNome = dados['interessadoNome'];
      final tituloPublicacao = dados['tituloPublicacao'];
      final publicacaoId = dados['publicacaoId'];

      if (doadorId is! String ||
          interessadoId is! String ||
          doadorNome is! String ||
          interessadoNome is! String ||
          tituloPublicacao is! String ||
          publicacaoId is! String) {
        throw Exception('Dados da conversa inválidos.');
      }

      if (uid != doadorId && uid != interessadoId) {
        throw Exception('Participante da conversa inválido.');
      }

      final destinatarioId =
      uid == doadorId ? interessadoId : doadorId;

      final remetenteNome =
      uid == doadorId ? doadorNome : interessadoNome;

      if (destinatarioId.trim().isEmpty ||
          destinatarioId == uid ||
          !participantes.contains(destinatarioId)) {
        throw Exception('Destinatário da mensagem inválido.');
      }

      if (remetenteNome.trim().isEmpty ||
          tituloPublicacao.trim().isEmpty ||
          publicacaoId.trim().isEmpty) {
        throw Exception('Dados da notificação inválidos.');
      }

      transacao.set(mensagemRef, {
        'remetenteId': uid,
        'texto': mensagemTexto,
        'dataEnvio': FieldValue.serverTimestamp(),
      });

      transacao.update(conversaRef, {
        'ultimaMensagem': mensagemTexto,
        'ultimaMensagemRemetenteId': uid,
        'dataUltimaMensagem': FieldValue.serverTimestamp(),
      });

      _notificacaoControl.adicionarNaTransacao(
        transacao: transacao,
        tipo: 'nova_mensagem',
        titulo: 'Nova mensagem',
        mensagem:
        '${remetenteNome.trim()} enviou uma mensagem sobre '
            '"${tituloPublicacao.trim()}".',
        remetenteId: uid,
        remetenteNome: remetenteNome.trim(),
        destinatarioId: destinatarioId,
        eventoId: mensagemRef.id,
        publicacaoId: publicacaoId.trim(),
        conversaId: id,
      );
    });
  }
}