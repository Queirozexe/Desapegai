import 'package:flutter/material.dart';

import '../controller/interesse_control.dart';
import '../controller/publicacao_control.dart';
import '../model/publicacao.dart';
import '../theme/app_theme.dart';
import '../widgets/botoes.dart';

import 'cadastro_publicacao_screen.dart';
import 'detalhes_publicacao_screen.dart';
import 'profile_screen.dart';
import 'interessados_screen.dart';

enum _FiltroMinhasPublicacoes {
  disponiveis,
  emAndamento,
  concluidas,
}

class MinhasPublicacoesScreen extends StatefulWidget {
  const MinhasPublicacoesScreen({super.key});

  @override
  State<MinhasPublicacoesScreen> createState() =>
      _MinhasPublicacoesScreenState();
}

class _MinhasPublicacoesScreenState
    extends State<MinhasPublicacoesScreen> {
  final PublicacaoControl _publicacaoControl = PublicacaoControl();
  final InteresseControl _interesseControl = InteresseControl();

  late final Stream<List<Publicacao>> _publicacoesStream;

  final Map<String, Stream<int>> _streamsInteresses = {};

  _FiltroMinhasPublicacoes _filtroSelecionado =
      _FiltroMinhasPublicacoes.disponiveis;

  @override
  void initState() {
    super.initState();

    _publicacoesStream =
        _publicacaoControl.acompanharMinhasPublicacoes();
  }

  String _statusDoFiltro(_FiltroMinhasPublicacoes filtro) {
    switch (filtro) {
      case _FiltroMinhasPublicacoes.disponiveis:
        return 'ativa';
      case _FiltroMinhasPublicacoes.emAndamento:
        return 'em_andamento';
      case _FiltroMinhasPublicacoes.concluidas:
        return 'concluida';
    }
  }

  String _rotuloFiltro(_FiltroMinhasPublicacoes filtro) {
    switch (filtro) {
      case _FiltroMinhasPublicacoes.disponiveis:
        return 'Disponíveis';
      case _FiltroMinhasPublicacoes.emAndamento:
        return 'Em andamento';
      case _FiltroMinhasPublicacoes.concluidas:
        return 'Concluídas';
    }
  }

  String _rotuloStatus(String status) {
    switch (status) {
      case 'ativa':
        return 'Disponível';
      case 'em_andamento':
        return 'Em andamento';
      case 'concluida':
        return 'Concluída';
      default:
        return status;
    }
  }

  Stream<int> _streamQuantidadeInteresses(Publicacao publicacao) {
    final id = publicacao.id;

    if (id == null || id.isEmpty) {
      return Stream<int>.value(0);
    }

    return _streamsInteresses.putIfAbsent(
      id,
          () => _interesseControl.acompanharQuantidadeInteresses(id),
    );
  }

  void _aviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Widget _imagemPadrao() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFD8E8DF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 32,
        color: AppColors.green,
      ),
    );
  }

  Widget _imagemPublicacao(Publicacao publicacao) {
    if (publicacao.imagens.isEmpty) {
      return _imagemPadrao();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        publicacao.imagens.first,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagemPadrao();
        },
      ),
    );
  }

  Widget _construirEtiquetaStatus(String status) {
    Color corFundo;
    Color corTexto;

    switch (status) {
      case 'ativa':
        corFundo = const Color(0xFFDDEFE3);
        corTexto = const Color(0xFF14503A);
        break;

      case 'em_andamento':
        corFundo = const Color(0xFFFBE7B5);
        corTexto = const Color(0xFF5C4300);
        break;

      case 'concluida':
        corFundo = const Color(0xFFE4E8EC);
        corTexto = const Color(0xFF2F3E48);
        break;

      default:
        corFundo = Colors.grey.shade200;
        corTexto = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _rotuloStatus(status),
        style: TextStyle(
          color: corTexto,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _construirCard(Publicacao publicacao) {
    return StreamBuilder<int>(
      stream: _streamQuantidadeInteresses(publicacao),
      builder: (context, snapshot) {
        final quantidade = snapshot.data ?? 0;
        final status = publicacao.status;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesPublicacaoScreen(
                          publicacao: publicacao,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      _imagemPublicacao(publicacao),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              publicacao.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 5,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _construirEtiquetaStatus(status),
                                Text(
                                  snapshot.hasError
                                      ? 'Interessados indisponíveis'
                                      : '$quantidade ${quantidade == 1 ? 'interessado' : 'interessados'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButtonTheme(
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
                        'Ver interessados',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InteressadosScreen(
                                publicacao: publicacao,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _aviso(
                          'A edição de publicações será implementada '
                              'em uma próxima etapa.',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        foregroundColor: const Color(0xFF1B2B24),
                        side: const BorderSide(color: Color(0xFF1B2B24)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Editar'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _aviso(
                          'A remoção de publicações será implementada '
                              'em uma próxima etapa.',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        foregroundColor: const Color(0xFF9A3412),
                        side: const BorderSide(color: Color(0xFF9A3412)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Remover'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construirFiltros(List<Publicacao> publicacoes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: _FiltroMinhasPublicacoes.values.map((filtro) {
          final status = _statusDoFiltro(filtro);

          final quantidade = publicacoes
              .where((publicacao) => publicacao.status == status)
              .length;

          final selecionado = filtro == _filtroSelecionado;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _filtroSelecionado = filtro;
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
                  backgroundColor: selecionado
                      ? AppColors.green
                      : Colors.white,
                  foregroundColor: selecionado
                      ? Colors.white
                      : const Color(0xFF1B2B24),
                  side: BorderSide(
                    color: selecionado
                        ? AppColors.green
                        : const Color(0xFFCFC8B8),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  '${_rotuloFiltro(filtro)} ($quantidade)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _construirLista(AsyncSnapshot<List<Publicacao>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Não foi possível carregar suas publicações. '
                'Verifique sua conexão e tente novamente.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final publicacoes = snapshot.data ?? [];

    final statusSelecionado = _statusDoFiltro(
      _filtroSelecionado,
    );

    final publicacoesFiltradas = publicacoes
        .where(
          (publicacao) => publicacao.status == statusSelecionado,
    )
        .toList();

    return Column(
      children: [
        _construirFiltros(publicacoes),
        const SizedBox(height: 12),
        Expanded(
          child: publicacoesFiltradas.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    publicacoes.isEmpty
                        ? 'Você ainda não publicou nenhum item.'
                        : 'Você ainda não possui publicações '
                        '${_rotuloFiltro(_filtroSelecionado).toLowerCase()}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (_filtroSelecionado ==
                      _FiltroMinhasPublicacoes.disponiveis) ...[
                    const SizedBox(height: 16),
                    Botoes(
                      'Publicar um item',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const CadastroPublicacaoScreen(),
                          ),
                              (route) => route.isFirst,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: publicacoesFiltradas.length,
            separatorBuilder: (context, index) =>
            const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _construirCard(
                publicacoesFiltradas[index],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 16, 16),
                  child: Text(
                    'Minhas publicações',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Publicacao>>(
                    stream: _publicacoesStream,
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.popUntil(
              context,
                  (route) => route.isFirst,
            );
            return;
          }

          if (index == 1) return;

          if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const CadastroPublicacaoScreen(),
              ),
                  (route) => route.isFirst,
            );
            return;
          }

          if (index == 4) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
                  (route) => route.isFirst,
            );
            return;
          }

          _aviso(
            'Esta funcionalidade será implementada em uma próxima etapa.',
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Minhas',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Doar',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Mensagens',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}