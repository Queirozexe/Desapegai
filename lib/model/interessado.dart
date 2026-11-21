import 'package:cloud_firestore/cloud_firestore.dart';

class Interessado {
  final String usuarioId;
  final String nomeUsuario;
  final String cidade;
  final String mensagem;
  final DateTime? dataCriacao;

  const Interessado({
    required this.usuarioId,
    required this.nomeUsuario,
    this.cidade = 'Localização não informada',
    this.mensagem = '',
    this.dataCriacao,
  });

  factory Interessado.fromMap(Map<String, dynamic> map) {
    final data = map['dataCriacao'];
    final cidade = map['cidade'];

    return Interessado(
      usuarioId: map['usuarioId'] as String? ?? '',
      nomeUsuario: map['nomeUsuario'] as String? ?? 'Nome indisponível',
      cidade: cidade is String && cidade.trim().isNotEmpty
          ? cidade.trim()
          : 'Localização não informada',
      mensagem: map['mensagem'] as String? ?? '',
      dataCriacao: data is Timestamp ? data.toDate() : null,
    );
  }
}