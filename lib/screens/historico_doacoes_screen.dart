import 'package:flutter/material.dart';

import '../controller/doacao_control.dart';
import '../controller/avaliacao_control.dart';
import '../model/avaliacao.dart';
import '../model/doacao.dart';
import '../theme/app_theme.dart';
import '../widgets/botoes.dart';
import '../widgets/input.dart';

class HistoricoDoacoesScreen extends StatefulWidget {
  const HistoricoDoacoesScreen({super.key});

  @override
  State<HistoricoDoacoesScreen> createState() => _HistoricoDoacoesScreenState();
}

class _HistoricoDoacoesScreenState extends State<HistoricoDoacoesScreen> {
  final DoacaoControl _doacaoControl = DoacaoControl();
  final AvaliacaoControl _avaliacaoControl = AvaliacaoControl();
  final Map<String, Stream<Avaliacao?>> _streamsAvaliacoes = {};

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

  Widget _construirEstrelas(int nota) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) => Icon(
          index < nota ? Icons.star : Icons.star_border,
          size: 17,
          color: index < nota ? AppColors.gold : AppColors.muted,
        ),
      ),
    );
  }

  Widget _construirAcaoAvaliacao(Doacao doacao) {
    final doacaoId = doacao.id;

    if (doacaoId == null || doacaoId.isEmpty) {
      return const SizedBox.shrink();
    }

    final stream = _streamsAvaliacoes.putIfAbsent(
      doacaoId,
          () => _avaliacaoControl.acompanharAvaliacaoDaDoacao(doacaoId),
    );

    return StreamBuilder<Avaliacao?>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            width: 100,
            height: 40,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox(
            width: 100,
            child: Text(
              'Não foi possível verificar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.muted,
              ),
            ),
          );
        }

        final avaliacao = snapshot.data;

        if (avaliacao != null) {
          return Tooltip(
            message: 'Sua avaliação: ${avaliacao.nota} de 5 estrelas',
            child: _construirEstrelas(avaliacao.nota),
          );
        }

        return SizedBox(
          width: 100,
          height: 40,
          child: Botoes(
            'Avaliar',
            onPressed: () => _abrirDialogoAvaliacao(doacao),
          ),
        );
      },
    );
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

  Future<void> _abrirDialogoAvaliacao(Doacao doacao) async {
    final doacaoId = doacao.id;

    if (doacaoId == null || doacaoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar a doação.'),
        ),
      );
      return;
    }

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FormularioAvaliacao(
          doacaoId: doacaoId,
          tituloPublicacao: doacao.tituloPublicacao,
          avaliacaoControl: _avaliacaoControl,
        );
      },
    );

    if (!mounted || resultado != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avaliação enviada com sucesso!'),
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
                      _construirAcaoAvaliacao(doacao),
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

class FormularioAvaliacao extends StatefulWidget {
  final String doacaoId;
  final String tituloPublicacao;
  final AvaliacaoControl avaliacaoControl;

  const FormularioAvaliacao({
    super.key,
    required this.doacaoId,
    required this.tituloPublicacao,
    required this.avaliacaoControl,
  });

  @override
  State<FormularioAvaliacao> createState() =>
      _FormularioAvaliacaoState();
}

class _FormularioAvaliacaoState extends State<FormularioAvaliacao> {
  final TextEditingController _comentarioController =
  TextEditingController();

  int _notaSelecionada = 0;
  bool _enviando = false;
  String? _mensagemErro;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviarAvaliacao() async {
    if (_notaSelecionada == 0 || _enviando) {
      return;
    }

    setState(() {
      _enviando = true;
      _mensagemErro = null;
    });

    try {
      await widget.avaliacaoControl.avaliarDoacao(
        doacaoId: widget.doacaoId,
        nota: _notaSelecionada,
        comentario: _comentarioController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _enviando = false;
        _mensagemErro = erro.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_enviando,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              22,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Como foi a experiência?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2B24),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.tituloPublicacao,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final estrela = index + 1;
                      final selecionada = estrela <= _notaSelecionada;

                      return IconButton(
                        onPressed: _enviando
                            ? null
                            : () {
                          setState(() {
                            _notaSelecionada = estrela;
                            _mensagemErro = null;
                          });
                        },
                        icon: Icon(
                          selecionada
                              ? Icons.star
                              : Icons.star_border,
                          size: 36,
                          color: selecionada
                              ? AppColors.gold
                              : AppColors.muted,
                        ),
                        constraints: const BoxConstraints.tightFor(
                          width: 52,
                          height: 52,
                        ),
                        padding: EdgeInsets.zero,
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  Input(
                    'Comentário (opcional)',
                    'A conversa foi tranquila? A retirada deu certo?',
                    controller: _comentarioController,
                    maxLines: 3,
                    maxLength: 500,
                    keyboardType: TextInputType.multiline,
                    mostrarContador: false,
                  ),
                  if (_mensagemErro != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _mensagemErro!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: Botoes(
                            _enviando
                                ? 'Enviando...'
                                : _notaSelecionada > 0
                                ? 'Enviar avaliação'
                                : 'Escolha uma nota',
                            onPressed: _notaSelecionada == 0 || _enviando
                                ? null
                                : _enviarAvaliacao,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _enviando
                                ? null
                                : () {
                              Navigator.of(context).pop(false);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.green,
                              side: const BorderSide(
                                color: AppColors.green,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}