class Usuario {
  final String uid;
  final String nome;
  final String email;
  final String cidade;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.cidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'cidade': cidade,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'],
      nome: map['nome'],
      email: map['email'],
      cidade: map['cidade'],
    );
  }
}
