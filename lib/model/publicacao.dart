import 'package:cloud_firestore/cloud_firestore.dart';

class Publicacao {
  final String? id;
  final String usuarioId;
  final String nomeDoador;
  final String titulo;
  final String descricao;
  final String categoria;
  final String estadoConservacao;
  final String cidade;
  final DateTime dataCriacao;
  final String status;
  final List<String> imagens;
  final String? usuarioEscolhidoId;
  final DateTime? dataConclusao;

  Publicacao({
    this.id,
    required this.usuarioId,
    this.nomeDoador = 'Doador',
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.estadoConservacao,
    required this.cidade,
    required this.dataCriacao,
    this.status = 'ativa',
    this.imagens = const [],
    this.usuarioEscolhidoId,
    this.dataConclusao,
  });

  Map<String, dynamic> toMap() {
    final dados = <String, dynamic>{
      'usuarioId': usuarioId,
      'nomeDoador': nomeDoador,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'estadoConservacao': estadoConservacao,
      'cidade': cidade,
      'dataCriacao': dataCriacao,
      'status': status,
      'imagens': imagens,
    };

    if (usuarioEscolhidoId != null) {
      dados['usuarioEscolhidoId'] = usuarioEscolhidoId!;
    }

    if (dataConclusao != null) {
      dados['dataConclusao'] = dataConclusao!;
    }

    return dados;
  }

  factory Publicacao.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    return Publicacao(
      id: id,
      usuarioId: map['usuarioId'] as String,
      nomeDoador: map['nomeDoador'] as String? ?? 'Doador',
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      categoria: map['categoria'] as String,
      estadoConservacao: map['estadoConservacao'] as String,
      cidade: map['cidade'] as String,
      dataCriacao: (map['dataCriacao'] as Timestamp).toDate(),
      status: map['status'] as String? ?? 'ativa',
      imagens: List<String>.from(map['imagens'] ?? []),
      usuarioEscolhidoId: map['usuarioEscolhidoId'] as String?,
      dataConclusao: map['dataConclusao'] is Timestamp
          ? (map['dataConclusao'] as Timestamp).toDate()
          : null,
    );
  }
}