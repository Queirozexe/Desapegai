import 'package:cloud_firestore/cloud_firestore.dart';

class Doacao {
  final String? id;
  final String publicacaoId;
  final String tituloPublicacao;
  final String? imagemPublicacao;
  final String doadorId;
  final String doadorNome;
  final String beneficiarioId;
  final String beneficiarioNome;
  final String beneficiarioCidade;
  final List<String> participantes;
  final DateTime dataConclusao;
  final String status;
  final DateTime? dataReabertura;

  Doacao({
    this.id,
    required this.publicacaoId,
    required this.tituloPublicacao,
    this.imagemPublicacao,
    required this.doadorId,
    required this.doadorNome,
    required this.beneficiarioId,
    required this.beneficiarioNome,
    required this.beneficiarioCidade,
    required this.participantes,
    required this.dataConclusao,
    this.status = 'concluida',
    this.dataReabertura,
  });

  Map<String, dynamic> toMap() {
    final dados = <String, dynamic>{
      'publicacaoId': publicacaoId,
      'tituloPublicacao': tituloPublicacao,
      'imagemPublicacao': imagemPublicacao,
      'doadorId': doadorId,
      'doadorNome': doadorNome,
      'beneficiarioId': beneficiarioId,
      'beneficiarioNome': beneficiarioNome,
      'beneficiarioCidade': beneficiarioCidade,
      'participantes': participantes,
      'dataConclusao': dataConclusao,
      'status': status,
    };

    if (dataReabertura != null) {
      dados['dataReabertura'] = dataReabertura!;
    }

    return dados;
  }

  factory Doacao.fromMap(Map<String, dynamic> map, String id) {
    return Doacao(
      id: id,
      publicacaoId: map['publicacaoId'] as String,
      tituloPublicacao: map['tituloPublicacao'] as String,
      imagemPublicacao: map['imagemPublicacao'] as String?,
      doadorId: map['doadorId'] as String,
      doadorNome: map['doadorNome'] as String,
      beneficiarioId: map['beneficiarioId'] as String,
      beneficiarioNome: map['beneficiarioNome'] as String,
      beneficiarioCidade: map['beneficiarioCidade'] as String,
      participantes: List<String>.from(map['participantes']),
      dataConclusao: (map['dataConclusao'] as Timestamp).toDate(),
      status: map['status'] as String? ?? 'concluida',
      dataReabertura:
          map['dataReabertura'] is Timestamp
              ? (map['dataReabertura'] as Timestamp).toDate()
              : null,
    );
  }
}
