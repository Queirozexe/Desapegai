import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  final String id;
  final String publicacaoId;
  final String tituloPublicacao;
  final String? imagemPublicacao;
  final String doadorId;
  final String doadorNome;
  final String interessadoId;
  final String interessadoNome;
  final List<String> participantes;
  final DateTime? dataCriacao;
  final String ultimaMensagem;
  final String? ultimaMensagemRemetenteId;
  final DateTime? dataUltimaMensagem;

  const Conversa({
    required this.id,
    required this.publicacaoId,
    required this.tituloPublicacao,
    this.imagemPublicacao,
    required this.doadorId,
    required this.doadorNome,
    required this.interessadoId,
    required this.interessadoNome,
    required this.participantes,
    this.dataCriacao,
    this.ultimaMensagem = '',
    this.ultimaMensagemRemetenteId,
    this.dataUltimaMensagem,
  });

  factory Conversa.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    final dataCriacao = map['dataCriacao'];
    final dataUltimaMensagem = map['dataUltimaMensagem'];

    return Conversa(
      id: id,
      publicacaoId: map['publicacaoId'] as String? ?? '',
      tituloPublicacao:
      map['tituloPublicacao'] as String? ?? 'Publicação',
      imagemPublicacao: map['imagemPublicacao'] as String?,
      doadorId: map['doadorId'] as String? ?? '',
      doadorNome: map['doadorNome'] as String? ?? 'Doador',
      interessadoId: map['interessadoId'] as String? ?? '',
      interessadoNome:
      map['interessadoNome'] as String? ?? 'Interessado',
      participantes: map['participantes'] is List
          ? List<String>.from(map['participantes'])
          : [],
      dataCriacao: dataCriacao is Timestamp
          ? dataCriacao.toDate()
          : null,
      ultimaMensagem: map['ultimaMensagem'] as String? ?? '',
      ultimaMensagemRemetenteId:
      map['ultimaMensagemRemetenteId'] as String?,
      dataUltimaMensagem: dataUltimaMensagem is Timestamp
          ? dataUltimaMensagem.toDate()
          : null,
    );
  }

  String nomeOutroParticipante(String usuarioAtualId) {
    if (usuarioAtualId == doadorId) {
      return interessadoNome;
    }

    if (usuarioAtualId == interessadoId) {
      return doadorNome;
    }

    return 'Usuário';
  }
}