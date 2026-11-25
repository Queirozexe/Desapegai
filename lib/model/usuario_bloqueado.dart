import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioBloqueado {
  final String usuarioId;
  final String nome;
  final DateTime? dataBloqueio;

  const UsuarioBloqueado({
    required this.usuarioId,
    required this.nome,
    this.dataBloqueio,
  });

  factory UsuarioBloqueado.fromMap(
      Map<String, dynamic> map,
      String usuarioId,
      ) {
    final data = map['dataBloqueio'];

    return UsuarioBloqueado(
      usuarioId: usuarioId,
      nome: map['nome'] is String ? map['nome'] : 'Usuário',
      dataBloqueio: data is Timestamp ? data.toDate() : null,
    );
  }
}
