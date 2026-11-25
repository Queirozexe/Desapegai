import 'package:cloud_firestore/cloud_firestore.dart';

class Avaliacao {
  final String id;
  final String doacaoId;
  final String publicacaoId;
  final String avaliadorId;
  final String avaliadoId;
  final int nota;
  final String comentario;
  final DateTime? dataCriacao;

  const Avaliacao({
    required this.id,
    required this.doacaoId,
    required this.publicacaoId,
    required this.avaliadorId,
    required this.avaliadoId,
    required this.nota,
    required this.comentario,
    required this.dataCriacao,
  });

  factory Avaliacao.fromMap(Map<String, dynamic> map, String id) {
    return Avaliacao(
      id: id,
      doacaoId: map['doacaoId'] as String,
      publicacaoId: map['publicacaoId'] as String,
      avaliadorId: map['avaliadorId'] as String,
      avaliadoId: map['avaliadoId'] as String,
      nota: map['nota'] as int,
      comentario: map['comentario'] as String? ?? '',
      dataCriacao: map['dataCriacao'] is Timestamp
          ? (map['dataCriacao'] as Timestamp).toDate()
          : null,
    );
  }
}

class ResumoAvaliacoes {
  final double media;
  final int quantidade;

  const ResumoAvaliacoes({
    required this.media,
    required this.quantidade,
  });

  String get texto {
    if (quantidade == 0) {
      return 'Novo';
    }

    return '${media.toStringAsFixed(1).replaceAll('.', ',')} ($quantidade)';
  }
}
