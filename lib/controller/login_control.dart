import 'package:firebase_auth/firebase_auth.dart';

class LoginControl {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> entrar({
    required String email,
    required String senha,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }
}