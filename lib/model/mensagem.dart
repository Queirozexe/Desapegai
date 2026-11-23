import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem {
  final String id;
  final String remetenteId;
  final String texto;
  final DateTime? dataEnvio;

  const Mensagem({
    required this.id,
    required this.remetenteId,
    required this.texto,
    this.dataEnvio,
  });

  factory Mensagem.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    final dataEnvio = map['dataEnvio'];

    return Mensagem(
      id: id,
      remetenteId: map['remetenteId'] as String? ?? '',
      texto: map['texto'] as String? ?? '',
      dataEnvio: dataEnvio is Timestamp
          ? dataEnvio.toDate()
          : null,
    );
  }
}