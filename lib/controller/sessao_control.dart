import 'package:firebase_auth/firebase_auth.dart';

class SessaoControl {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final Stream<User?> estadoAutenticacao =
  _auth.authStateChanges();

  Future<void> sair() async {
    await _auth.signOut();
  }
}
