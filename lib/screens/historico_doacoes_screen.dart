import 'package:flutter/material.dart';

import '../controller/doacao_control.dart';
import '../model/doacao.dart';
import '../theme/app_theme.dart';
import '../widgets/botoes.dart';

class HistoricoDoacoesScreen extends StatefulWidget {
  const HistoricoDoacoesScreen({super.key});

  @override
  State<HistoricoDoacoesScreen> createState() => _HistoricoDoacoesScreenState();
}

class _HistoricoDoacoesScreenState extends State<HistoricoDoacoesScreen> {
  final DoacaoControl _doacaoControl = DoacaoControl();

  late final Stream<List<Doacao>> _doacoesFeitasStream;
  late final Stream<List<Doacao>> _doacoesRecebidasStream;

  bool _mostrarFeitas = true;

  @override
  void initState() {
    super.initState();

    _doacoesFeitasStream = _doacaoControl.acompanharDoacoesFeitas();

    _doacoesRecebidasStream = _doacaoControl.acompanharDoacoesRecebidas();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  String _rotuloStatus(String status) {
    if (status == 'reaberta') {
      return 'Conclusão desfeita';
    }

    if (status == 'concluida') {
      return 'Doação concluída';
    }

    return status;
  }

  Widget _construirImagem(Doacao doacao) {
    final imagem = doacao.imagemPublicacao;

    if (imagem == null || imagem.trim().isEmpty) {
      return _imagemPadrao();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imagem,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagemPadrao();
        },
      ),
    );
  }

  Widget _imagemPadrao() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFD8E8DF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 34,
        color: AppColors.green,
      ),
    );
  }

  Widget _construirEtiquetaStatus(String status) {
    final reaberta = status == 'reaberta';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: reaberta ? const Color(0xFFFBE7B5) : const Color(0xFFDDEFE3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _rotuloStatus(status),
        style: TextStyle(
          color: reaberta ? const Color(0xFF5C4300) : const Color(0xFF14503A),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _construirCard(Doacao doacao, {required bool doacaoFeita}) {
    final nomeOutraParte =
        doacaoFeita ? doacao.beneficiarioNome : doacao.doadorNome;

    final tituloRelacao = doacaoFeita ? 'Beneficiário' : 'Doador';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DDCF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirImagem(doacao),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doacao.tituloPublicacao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2B24),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '$tituloRelacao: $nomeOutraParte',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF34443C),
                  ),
                ),

                if (doacaoFeita) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Cidade: ${doacao.beneficiarioCidade}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Text(
                  'Conclusão: ${_formatarData(doacao.dataConclusao)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    _construirEtiquetaStatus(doacao.status),
                    const Spacer(),
                    if (doacao.status == 'concluida')
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: Botoes(
                          'Avaliar',
                          onPressed: () {},
                        ),
                      ),
                  ],
                ),

                if (doacao.status == 'reaberta' &&
                    doacao.dataReabertura != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Reaberta em: ${_formatarData(doacao.dataReabertura!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirEstadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 52, color: AppColors.muted),
            const SizedBox(height: 14),
            Text(
              _mostrarFeitas
                  ? 'Você ainda não realizou nenhuma doação.'
                  : 'Você ainda não recebeu nenhuma doação.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLista(AsyncSnapshot<List<Doacao>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível carregar o histórico. '
            'Verifique sua conexão e tente novamente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.5),
          ),
        ),
      );
    }

    final doacoes = snapshot.data ?? [];

    if (doacoes.isEmpty) {
      return _construirEstadoVazio();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      itemCount: doacoes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _construirCard(doacoes[index], doacaoFeita: _mostrarFeitas);
      },
    );
  }

  Widget _construirOpcao({
    required String titulo,
    required IconData icone,
    required bool selecionada,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icone, size: 19),
        label: Text(
          titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          backgroundColor: selecionada ? AppColors.green : Colors.white,
          foregroundColor: selecionada ? Colors.white : const Color(0xFF1B2B24),
          side: BorderSide(
            color: selecionada ? AppColors.green : const Color(0xFFCFC8B8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream =
        _mostrarFeitas ? _doacoesFeitasStream : _doacoesRecebidasStream;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Histórico de doações',
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(
                    children: [
                      _construirOpcao(
                        titulo: 'Doações feitas',
                        icone: Icons.volunteer_activism_outlined,
                        selecionada: _mostrarFeitas,
                        onTap: () {
                          setState(() {
                            _mostrarFeitas = true;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _construirOpcao(
                        titulo: 'Doações recebidas',
                        icone: Icons.card_giftcard_outlined,
                        selecionada: !_mostrarFeitas,
                        onTap: () {
                          setState(() {
                            _mostrarFeitas = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<List<Doacao>>(
                    stream: stream,
                    builder: (context, snapshot) {
                      return _construirLista(snapshot);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
