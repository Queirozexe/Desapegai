import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/denuncia.dart';

class DenunciaControl {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> motivosPublicacao = [
    'Item proibido ou perigoso',
    'Cobrança de valores ou tentativa de venda',
    'Conduta inadequada ou ofensiva',
    'Informações falsas ou fotos que não correspondem',
    'Spam ou conteúdo repetido',
    'Outro',
  ];

  static const List<String> motivosUsuario = [
    'Item proibido ou perigoso',
    'Cobrança de valores ou tentativa de venda',
    'Conduta inadequada ou ofensiva',
    'Informações falsas ou fotos que não correspondem',
    'Spam ou conteúdo repetido',
    'Outro',
  ];

  String _obterUidUsuarioAtual() {
    final uid = _auth.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw StateError('Nenhum usuário autenticado.');
    }

    return uid;
  }

  String _validarMotivo(
      String motivo,
      List<String> motivosPermitidos,
      ) {
    final motivoLimpo = motivo.trim();

    if (!motivosPermitidos.contains(motivoLimpo)) {
      throw ArgumentError('Motivo de denúncia inválido.');
    }

    return motivoLimpo;
  }

  String _validarDescricao(String descricao) {
    final descricaoLimpa = descricao.trim();

    if (descricaoLimpa.length > 500) {
      throw ArgumentError(
        'A descrição deve ter no máximo 500 caracteres.',
      );
    }

    return descricaoLimpa;
  }

  Future<void> denunciarPublicacao({
    required String publicacaoId,
    required String motivo,
    String descricao = '',
  }) async {
    final uid = _obterUidUsuarioAtual();
    final id = publicacaoId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID da publicação inválido.');
    }

    final motivoValidado = _validarMotivo(
      motivo,
      motivosPublicacao,
    );

    final descricaoValidada = _validarDescricao(descricao);

    final documento = await _firestore
        .collection('publicacoes')
        .doc(id)
        .get();

    if (!documento.exists) {
      throw StateError('Publicação não encontrada.');
    }

    final dados = documento.data()!;

    final denunciadoId = dados['usuarioId'];
    final titulo = dados['titulo'];

    if (denunciadoId is! String ||
        denunciadoId.isEmpty ||
        titulo is! String ||
        titulo.trim().isEmpty) {
      throw StateError('Dados da publicação inválidos.');
    }

    if (denunciadoId == uid) {
      throw StateError('Você não pode denunciar sua própria publicação.');
    }

    final denuncia = Denuncia(
      denuncianteId: uid,
      denunciadoId: denunciadoId,
      tipo: 'publicacao',
      publicacaoId: id,
      tituloPublicacao: titulo,
      motivo: motivoValidado,
      descricao: descricaoValidada,
    );

    await _firestore
        .collection('denuncias')
        .add(denuncia.toMap());
  }

  Future<void> denunciarUsuario({
    required String conversaId,
    required String motivo,
    String descricao = '',
  }) async {
    final uid = _obterUidUsuarioAtual();
    final id = conversaId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID da conversa inválido.');
    }

    final motivoValidado = _validarMotivo(
      motivo,
      motivosUsuario,
    );

    final descricaoValidada = _validarDescricao(descricao);

    final documento = await _firestore
        .collection('conversas')
        .doc(id)
        .get();

    if (!documento.exists) {
      throw StateError('Conversa não encontrada.');
    }

    final dados = documento.data()!;

    final doadorId = dados['doadorId'];
    final interessadoId = dados['interessadoId'];
    final publicacaoId = dados['publicacaoId'];
    final titulo = dados['tituloPublicacao'];
    final participantes = dados['participantes'];

    if (doadorId is! String ||
        interessadoId is! String ||
        publicacaoId is! String ||
        titulo is! String ||
        participantes is! List) {
      throw StateError('Dados da conversa inválidos.');
    }

    if (doadorId == interessadoId ||
        !participantes.contains(uid) ||
        !participantes.contains(doadorId) ||
        !participantes.contains(interessadoId)) {
      throw StateError(
        'Você não tem permissão para denunciar por esta conversa.',
      );
    }

    final denunciadoId = uid == doadorId
        ? interessadoId
        : doadorId;

    final denuncia = Denuncia(
      denuncianteId: uid,
      denunciadoId: denunciadoId,
      tipo: 'usuario',
      publicacaoId: publicacaoId,
      tituloPublicacao: titulo,
      conversaId: id,
      motivo: motivoValidado,
      descricao: descricaoValidada,
    );

    await _firestore
        .collection('denuncias')
        .add(denuncia.toMap());
  }
}
