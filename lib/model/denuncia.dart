import 'package:cloud_firestore/cloud_firestore.dart';

class Denuncia {
  final String denuncianteId;
  final String denunciadoId;
  final String tipo;
  final String publicacaoId;
  final String tituloPublicacao;
  final String? conversaId;
  final String motivo;
  final String descricao;

  const Denuncia({
    required this.denuncianteId,
    required this.denunciadoId,
    required this.tipo,
    required this.publicacaoId,
    required this.tituloPublicacao,
    this.conversaId,
    required this.motivo,
    required this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'denuncianteId': denuncianteId,
      'denunciadoId': denunciadoId,
      'tipo': tipo,
      'publicacaoId': publicacaoId,
      'tituloPublicacao': tituloPublicacao,
      'conversaId': conversaId,
      'motivo': motivo,
      'descricao': descricao,
      'dataCriacao': FieldValue.serverTimestamp(),
      'status': 'pendente',
    };
  }
}
