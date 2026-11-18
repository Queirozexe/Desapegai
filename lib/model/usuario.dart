class Usuario {
  final String uid;
  final String nome;
  final String email;
  final String cidade;
  final String sobreMim;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.cidade,
    this.sobreMim = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'cidade': cidade,
      'sobreMim': sobreMim,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'],
      nome: map['nome'],
      email: map['email'],
      cidade: map['cidade'],
      sobreMim: map['sobreMim'] ?? '',
    );
  }
}
