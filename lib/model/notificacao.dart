import 'package:cloud_firestore/cloud_firestore.dart';

class Notificacao {
  final String id;
  final String tipo;
  final String titulo;
  final String mensagem;
  final String remetenteId;
  final String? remetenteNome;
  final String destinatarioId;
  final String eventoId;
  final String? publicacaoId;
  final String? conversaId;
  final String? doacaoId;
  final bool lida;
  final DateTime? dataCriacao;

  const Notificacao({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensagem,
    required this.remetenteId,
    this.remetenteNome,
    required this.destinatarioId,
    required this.eventoId,
    this.publicacaoId,
    this.conversaId,
    this.doacaoId,
    required this.lida,
    this.dataCriacao,
  });

  factory Notificacao.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    final dataCriacao = map['dataCriacao'];

    return Notificacao(
      id: id,
      tipo: map['tipo'] as String? ?? '',
      titulo: map['titulo'] as String? ?? 'Notificação',
      mensagem: map['mensagem'] as String? ?? '',
      remetenteId: map['remetenteId'] as String? ?? '',
      remetenteNome: map['remetenteNome'] as String?,
      destinatarioId: map['destinatarioId'] as String? ?? '',
      eventoId: map['eventoId'] as String? ?? '',
      publicacaoId: map['publicacaoId'] as String?,
      conversaId: map['conversaId'] as String?,
      doacaoId: map['doacaoId'] as String?,
      lida: map['lida'] as bool? ?? false,
      dataCriacao: dataCriacao is Timestamp
          ? dataCriacao.toDate()
          : null,
    );
  }
}