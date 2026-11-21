import 'package:flutter/material.dart';

import '../controller/interesse_control.dart';
import '../model/interessado.dart';
import '../model/publicacao.dart';
import '../theme/app_theme.dart';

class InteressadosScreen extends StatefulWidget {
  final Publicacao publicacao;

  const InteressadosScreen({
    super.key,
    required this.publicacao,
  });

  @override
  State<InteressadosScreen> createState() =>
      _InteressadosScreenState();
}

class _InteressadosScreenState extends State<InteressadosScreen> {
  late final Stream<List<Interessado>> _interessadosStream;

  @override
  void initState() {
    super.initState();

    final id = widget.publicacao.id;

    if (id == null || id.trim().isEmpty) {
      _interessadosStream = Stream.error(
        StateError('Publicação sem identificador válido.'),
      );
    } else {
      _interessadosStream =
          InteresseControl().acompanharInteressados(id);
    }
  }

  String _gerarIniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) return '?';

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  String _formatarData(DateTime? data) {
    if (data == null) {
      return 'Data do interesse indisponível';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return 'Demonstrou interesse em $dia/$mes/${data.year}';
  }

  Widget _construirCard(Interessado interessado) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE3DDCF),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFDDEFE3),
              child: Text(
                _gerarIniciais(interessado.nomeUsuario),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    interessado.nomeUsuario,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2B24),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatarData(interessado.dataCriacao),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLista(AsyncSnapshot<List<Interessado>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível carregar os interessados. '
                'Verifique sua conexão e tente novamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    final interessados = snapshot.data ?? [];

    if (interessados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: AppColors.muted,
              ),
              SizedBox(height: 12),
              Text(
                'Ainda não há interessados nesta publicação.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: interessados.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _construirCard(interessados[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Interessados',
          style: TextStyle(
            color: Color(0xFF1B2B24),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black87,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.publicacao.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2B24),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Pessoas interessadas nesta doação',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Interessado>>(
                stream: _interessadosStream,
                builder: (context, snapshot) {
                  return _construirLista(snapshot);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}