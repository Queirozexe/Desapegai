import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/usuario_bloqueado.dart';

class BloqueioControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _obterUidUsuarioAtual() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  String _validarUsuarioId(String usuarioId) {
    final id = usuarioId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID do usuário inválido.');
    }

    return id;
  }

  CollectionReference<Map<String, dynamic>> _colecaoBloqueados(
      String usuarioId,
      ) {
    return _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('bloqueados');
  }

  Future<void> bloquearUsuario({
    required String usuarioId,
    required String nome,
  }) async {
    final uid = _obterUidUsuarioAtual();
    final id = _validarUsuarioId(usuarioId);
    final nomeUsuario = nome.trim();

    if (id == uid) {
      throw ArgumentError('Você não pode bloquear a si mesmo.');
    }

    if (nomeUsuario.isEmpty) {
      throw ArgumentError('Nome do usuário inválido.');
    }

    await _colecaoBloqueados(uid).doc(id).set({
      'usuarioId': id,
      'nome': nomeUsuario,
      'dataBloqueio': FieldValue.serverTimestamp(),
    });
  }

  Future<void> desbloquearUsuario(String usuarioId) async {
    final uid = _obterUidUsuarioAtual();
    final id = _validarUsuarioId(usuarioId);

    await _colecaoBloqueados(uid).doc(id).delete();
  }

  Stream<bool> acompanharBloqueioFeitoPorMim(
      String outroUsuarioId,
      ) {
    final uid = _obterUidUsuarioAtual();
    final outroId = _validarUsuarioId(outroUsuarioId);

    if (uid == outroId) {
      return Stream<bool>.value(false);
    }

    return _colecaoBloqueados(uid)
        .doc(outroId)
        .snapshots()
        .map((documento) => documento.exists);
  }

  Stream<List<UsuarioBloqueado>> acompanharUsuariosBloqueados() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Stream<List<UsuarioBloqueado>>.error(
        Exception('Usuário não autenticado.'),
      );
    }

    return _colecaoBloqueados(uid)
        .orderBy('dataBloqueio', descending: true)
        .snapshots()
        .map((resultado) {
      return resultado.docs.map((documento) {
        return UsuarioBloqueado.fromMap(
          documento.data(),
          documento.id,
        );
      }).toList();
    });
  }

  Stream<bool> acompanharBloqueioEntreUsuarios(
      String outroUsuarioId,
      ) {
    final uid = _obterUidUsuarioAtual();
    final outroId = _validarUsuarioId(outroUsuarioId);

    if (uid == outroId) {
      return Stream<bool>.value(false);
    }

    final referenciaAtual = _colecaoBloqueados(uid).doc(outroId);
    final referenciaOutro = _colecaoBloqueados(outroId).doc(uid);

    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    inscricaoAtual;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    inscricaoOutro;

    bool? bloqueioAtual;
    bool? bloqueioOutro;

    late final StreamController<bool> controller;

    void publicarEstado() {
      if (bloqueioAtual != null && bloqueioOutro != null) {
        controller.add(bloqueioAtual! || bloqueioOutro!);
      }
    }

    controller = StreamController<bool>(
      onListen: () {
        inscricaoAtual = referenciaAtual.snapshots().listen(
              (documento) {
            bloqueioAtual = documento.exists;
            publicarEstado();
          },
          onError: (erro, stackTrace) {
            controller.addError(erro, stackTrace);
          },
        );

        inscricaoOutro = referenciaOutro.snapshots().listen(
              (documento) {
            bloqueioOutro = documento.exists;
            publicarEstado();
          },
          onError: (erro, stackTrace) {
            controller.addError(erro, stackTrace);
          },
        );
      },
      onCancel: () async {
        await inscricaoAtual?.cancel();
        await inscricaoOutro?.cancel();
      },
    );

    return controller.stream;
  }

  Stream<Set<String>> acompanharIdsComBloqueio() {
    final uid = _obterUidUsuarioAtual();
    final controlador = StreamController<Set<String>>();

    Set<String>? idsBloqueadosPorMim;
    Set<String>? idsQueMeBloquearam;

    void emitir() {
      if (idsBloqueadosPorMim == null ||
          idsQueMeBloquearam == null ||
          controlador.isClosed) {
        return;
      }

      controlador.add({
        ...idsBloqueadosPorMim!,
        ...idsQueMeBloquearam!,
      });
    }

    final inscricaoBloqueadosPorMim = _colecaoBloqueados(
      uid,
    ).snapshots().listen(
          (resultado) {
        idsBloqueadosPorMim = resultado.docs
            .map((documento) => documento.id)
            .toSet();

        emitir();
      },
      onError: controlador.addError,
    );

    final inscricaoQuemMeBloqueou = _firestore
        .collectionGroup('bloqueados')
        .where('usuarioId', isEqualTo: uid)
        .snapshots()
        .listen(
          (resultado) {
        idsQueMeBloquearam = resultado.docs
            .map(
              (documento) =>
          documento.reference.parent.parent?.id,
        )
            .whereType<String>()
            .toSet();

        emitir();
      },
      onError: controlador.addError,
    );

    controlador.onCancel = () async {
      await inscricaoBloqueadosPorMim.cancel();
      await inscricaoQuemMeBloqueou.cancel();
    };

    return controlador.stream;
  }
}
