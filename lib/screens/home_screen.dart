
import 'package:flutter/material.dart';
import 'package:desapegai/theme/app_theme.dart';

import '../controller/sessao_control.dart';
import '../controller/usuario_control.dart';
import '../controller/publicacao_control.dart';
import '../model/usuario.dart';
import '../model/publicacao.dart';

import 'profile_screen.dart';
import 'cadastro_publicacao_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _busca = '';
  String _categoria = 'Todos';

  final SessaoControl _sessaoControl = SessaoControl();
  final UsuarioControl _usuarioControl = UsuarioControl();
  final PublicacaoControl _publicacaoControl = PublicacaoControl();

  late final Future<Usuario?> _usuarioFuture;
  late final Stream<List<Publicacao>> _publicacoesStream;

  @override
  void initState() {
    super.initState();

    _usuarioFuture = _usuarioControl.buscarUsuarioAtual();
    _publicacoesStream = _publicacaoControl.acompanharPublicacoes();
  }

  void _aviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _sair() async {
    try {
      await _sessaoControl.sair();
    } catch (e, stackTrace) {
      debugPrint('Erro ao encerrar sessão: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _aviso('Não foi possível sair. Tente novamente.');
    }
  }

  String _normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c');
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
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagemPadrao();
        },
      ),
    );
  }

  Widget _construirCard(Publicacao publicacao) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _aviso('Detalhes da publicação serão implementados depois.');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${publicacao.categoria} · ${publicacao.estadoConservacao}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            publicacao.cidade,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
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
      ),
    );
  }

  Widget _construirListaPublicacoes(
      AsyncSnapshot<List<Publicacao>> snapshot,
      ) {
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
            'Não foi possível carregar as publicações. '
                'Verifique sua conexão e tente novamente.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final publicacoes = snapshot.data ?? [];

    final categoriasDisponiveis = publicacoes
        .map((publicacao) => publicacao.categoria.trim())
        .where((categoria) => categoria.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final categorias = [
      'Todos',
      ...categoriasDisponiveis,
    ];

    final termo = _normalizarTexto(_busca);

    final publicacoesFiltradas = publicacoes.where((publicacao) {
      final correspondeCategoria =
          _categoria == 'Todos' ||
              _normalizarTexto(publicacao.categoria) ==
                  _normalizarTexto(_categoria);

      final correspondeBusca =
          termo.isEmpty ||
              _normalizarTexto(publicacao.titulo).contains(termo) ||
              _normalizarTexto(publicacao.descricao).contains(termo) ||
              _normalizarTexto(publicacao.categoria).contains(termo) ||
              _normalizarTexto(publicacao.cidade).contains(termo);

      return correspondeCategoria && correspondeBusca;
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categorias.length,
            separatorBuilder: (context, index) =>
            const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              final selecionada = _categoria == categoria;

              return ChoiceChip(
                label: Text(categoria),
                selected: selecionada,
                selectedColor: AppColors.green,
                labelStyle: TextStyle(
                  color: selecionada
                      ? Colors.white
                      : Colors.black87,
                ),
                onSelected: (valor) {
                  if (valor) {
                    setState(() {
                      _categoria = categoria;
                    });
                  }
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${publicacoesFiltradas.length} itens disponíveis',
            style: const TextStyle(
              color: AppColors.muted,
            ),
          ),
        ),
        Expanded(
          child: publicacoesFiltradas.isEmpty
              ? Center(
            child: Text(
              publicacoes.isEmpty
                  ? 'Ainda não há publicações disponíveis.'
                  : 'Nenhum item corresponde à sua busca ou categoria.',
              textAlign: TextAlign.center,
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            itemCount: publicacoesFiltradas.length,
            separatorBuilder: (context, index) =>
            const SizedBox(height: 10),
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    8,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Desapegaí',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                        ),
                        onPressed: () => _aviso(
                          'Notificações serão implementadas depois.',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_outlined),
                        tooltip: 'Sair',
                        onPressed: _sair,
                      ),
                    ],
                  ),
                ),
                FutureBuilder<Usuario?>(
                  future: _usuarioFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: LinearProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Não foi possível carregar os dados do perfil.',
                        ),
                      );
                    }

                    final usuario = snapshot.data;

                    final nome = usuario?.nome.trim();
                    final cidade = usuario?.cidade.trim();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome != null && nome.isNotEmpty
                                ? 'Olá, $nome!'
                                : 'Olá!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  cidade != null && cidade.isNotEmpty
                                      ? 'Cidade: $cidade'
                                      : 'Perfil não encontrado ou sem cidade.',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => _aviso(
                                  'Filtro de distância em desenvolvimento.',
                                ),
                                child: const Text('Até 10 km'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (valor) {
                      setState(() {
                        _busca = valor;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Buscar publicação, categoria, cidade...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Publicacao>>(
                    stream: _publicacoesStream,
                    builder: (context, snapshot) {
                      return _construirListaPublicacoes(snapshot);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 0) {
            return;
          }

          if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const CadastroPublicacaoScreen(),
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
