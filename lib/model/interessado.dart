import 'package:cloud_firestore/cloud_firestore.dart';

class Interessado {
  final String usuarioId;
  final String nomeUsuario;
  final DateTime? dataCriacao;

  const Interessado({
    required this.usuarioId,
    required this.nomeUsuario,
    this.dataCriacao,
  });

  factory Interessado.fromMap(Map<String, dynamic> map) {
    final data = map['dataCriacao'];

    return Interessado(
      usuarioId: map['usuarioId'] as String? ?? '',
      nomeUsuario: map['nomeUsuario'] as String? ?? 'Nome indisponível',
      dataCriacao: data is Timestamp ? data.toDate() : null,
    );
  }
}