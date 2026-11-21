import 'package:flutter/material.dart';

import '../controller/interesse_control.dart';
import '../controller/publicacao_control.dart';
import '../model/interessado.dart';
import '../model/publicacao.dart';
import '../theme/app_theme.dart';
import '../widgets/botoes.dart';

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

  final PublicacaoControl _publicacaoControl = PublicacaoControl();

  String? _usuarioEscolhidoId;
  bool _processandoEscolha = false;
  bool _doacaoConcluida = false;
  bool _doacaoEmAndamento = false;

  @override
  void initState() {
    super.initState();

    _usuarioEscolhidoId = widget.publicacao.usuarioEscolhidoId;
    _doacaoConcluida = widget.publicacao.status == 'concluida';
    _doacaoEmAndamento = widget.publicacao.status == 'em_andamento';

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

  Future<void> _escolherInteressado(Interessado interessado) async {
    final publicacaoId = widget.publicacao.id;

    if (publicacaoId == null || publicacaoId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identificador da publicação inválido.'),
        ),
      );
      return;
    }

    setState(() {
      _processandoEscolha = true;
    });

    try {
      await _publicacaoControl.escolherInteressado(
        publicacaoId: publicacaoId,
        usuarioEscolhidoId: interessado.usuarioId,
      );

      if (!mounted) return;

      setState(() {
        _usuarioEscolhidoId = interessado.usuarioId;
        _doacaoEmAndamento = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${interessado.nomeUsuario} foi escolhido(a) para receber a doação!',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível realizar a escolha: ${erro.toString()}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processandoEscolha = false;
        });
      }
    }
  }

  Future<void> _desfazerEscolha() async {
    final publicacaoId = widget.publicacao.id;

    if (publicacaoId == null || publicacaoId.trim().isEmpty) {
      return;
    }

    setState(() {
      _processandoEscolha = true;
    });

    try {
      await _publicacaoControl.desfazerEscolha(
        publicacaoId: publicacaoId,
      );

      if (!mounted) return;

      setState(() {
        _usuarioEscolhidoId = null;
        _doacaoEmAndamento = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Escolha desfeita. A publicação voltou a ficar disponível.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível desfazer a escolha.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processandoEscolha = false;
        });
      }
    }
  }

  Future<void> _marcarDoacaoConcluida() async {
    final publicacaoId = widget.publicacao.id;

    if (publicacaoId == null || publicacaoId.trim().isEmpty) {
      return;
    }

    setState(() {
      _processandoEscolha = true;
    });

    try {
      await _publicacaoControl.concluirDoacao(
        publicacaoId: publicacaoId,
      );

      if (!mounted) return;

      setState(() {
        _doacaoConcluida = true;
        _doacaoEmAndamento = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doação marcada como concluída!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível concluir a doação.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processandoEscolha = false;
        });
      }
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

    return 'Interessado em $dia/$mes/${data.year}';
  }

  Widget _imagemPadraoPublicacao() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFD8E8DF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 30,
        color: AppColors.green,
      ),
    );
  }

  Widget _imagemPublicacao() {
    final imagens = widget.publicacao.imagens;

    if (imagens.isEmpty || imagens.first.trim().isEmpty) {
      return _imagemPadraoPublicacao();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imagens.first,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagemPadraoPublicacao();
        },
      ),
    );
  }

  Widget _construirEtiquetaStatus() {
    final status = _doacaoConcluida
        ? 'concluida'
        : _doacaoEmAndamento
        ? 'em_andamento'
        : 'ativa';

    Color corFundo;
    Color corTexto;
    String texto;

    switch (status) {
      case 'ativa':
        corFundo = const Color(0xFFDDEFE3);
        corTexto = const Color(0xFF14503A);
        texto = 'Disponível';
        break;

      case 'em_andamento':
        corFundo = const Color(0xFFFBE7B5);
        corTexto = const Color(0xFF5C4300);
        texto = 'Em andamento';
        break;

      case 'concluida':
        corFundo = const Color(0xFFE4E8EC);
        corTexto = const Color(0xFF2F3E48);
        texto = 'Concluída';
        break;

      default:
        corFundo = Colors.grey.shade200;
        corTexto = Colors.black87;
        texto = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: corTexto,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _construirResumoPublicacao() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3DDCF),
        ),
      ),
      child: Row(
        children: [
          _imagemPublicacao(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.publicacao.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    color: Color(0xFF1B2B24),
                  ),
                ),
                const SizedBox(height: 6),
                _construirEtiquetaStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCard(Interessado interessado) {
    final selecionado =
        _usuarioEscolhidoId == interessado.usuarioId;

    final podeEscolher =
        _usuarioEscolhidoId == null &&
            !_doacaoEmAndamento &&
            !_doacaoConcluida;

    final aguardando =
        _usuarioEscolhidoId != null && !selecionado;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selecionado
              ? AppColors.green
              : const Color(0xFFE3DDCF),
          width: selecionado ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFDDD3EB),
                child: Text(
                  _gerarIniciais(interessado.nomeUsuario),
                  style: const TextStyle(
                    color: Color(0xFF49365F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      interessado.nomeUsuario,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2B24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            interessado.cidade,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
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

          if (interessado.mensagem.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F1E8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                '“${interessado.mensagem}”',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF34443C),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          if (selecionado) ...[
            Text(
              _doacaoConcluida
                  ? 'Doação concluída'
                  : 'Escolhido(a) para receber',
              style: const TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            if (!_doacaoConcluida) ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: Botoes(
                        'Conversar',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'A funcionalidade de conversa ainda não está disponível.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _processandoEscolha
                            ? null
                            : _marcarDoacaoConcluida,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.green,
                          side: const BorderSide(
                            color: AppColors.green,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _processandoEscolha
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Marcar concluída',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ] else if (podeEscolher) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _processandoEscolha
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : ElevatedButtonTheme(
                data: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                child: Botoes(
                  'Escolher para a doação',
                  onPressed: () => _escolherInteressado(interessado),
                ),
              ),
            ),
          ] else if (aguardando) ...[
            const Text(
              'A doação seguirá com outra pessoa.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirLista(AsyncSnapshot<List<Interessado>> snapshot) {
    final interessados = snapshot.data ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        _construirResumoPublicacao(),

        if (_doacaoConcluida) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDDEFE3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF14503A),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Doação concluída!',
                      style: TextStyle(
                        color: Color(0xFF14503A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Obrigado por dar uma nova vida a esse item.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF34443C),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) ...[
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ]

        else if (snapshot.hasError) ...[
          const Padding(
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
        ]

        else ...[
            Padding(
              padding: const EdgeInsets.only(
                top: 18,
                bottom: 12,
              ),
              child: Text(
                interessados.length == 1
                    ? '1 pessoa quer este item'
                    : '${interessados.length} pessoas querem este item',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2B24),
                ),
              ),
            ),

            if (interessados.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 8,
                ),
                child: Text(
                  'Ninguém demonstrou interesse ainda. '
                      'Avisaremos quando alguém pedir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              )
            else
              for (final interessado in interessados)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _construirCard(interessado),
                ),
            if (_doacaoEmAndamento &&
                _usuarioEscolhidoId != null &&
                !_doacaoConcluida)
              OutlinedButton(
                onPressed: _processandoEscolha
                    ? null
                    : _desfazerEscolha,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: const Color(0xFF1B2B24),
                  side: const BorderSide(
                    color: Color(0xFFCFC8B8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Desfazer escolha'),
              ),
          ],
      ],
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
        child: StreamBuilder<List<Interessado>>(
          stream: _interessadosStream,
          builder: (context, snapshot) {
            return _construirLista(snapshot);
          },
        ),
      ),
    );
  }
}