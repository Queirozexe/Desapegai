import 'package:flutter/material.dart';
import 'package:desapegai/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

import '../controller/sessao_control.dart';
import '../controller/usuario_control.dart';
import '../controller/publicacao_control.dart';
import '../controller/notificacao_control.dart';
import '../model/usuario.dart';
import '../model/publicacao.dart';
import '../services/localizacao_service.dart';

import 'profile_screen.dart';
import 'cadastro_publicacao_screen.dart';
import 'detalhes_publicacao_screen.dart';
import 'minhas_publicacoes_screen.dart';
import 'conversas_screen.dart';
import 'notificacoes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _busca = '';
  String _categoria = 'Todos';
  double? _distanciaMaximaKm;
  bool _painelDistanciaAberto = false;
  bool _buscandoLocalizacao = false;

  CoordenadasLocalizacao? _coordenadasUsuario;

  final LocalizacaoService _localizacaoService = LocalizacaoService();
  final SessaoControl _sessaoControl = SessaoControl();
  final UsuarioControl _usuarioControl = UsuarioControl();
  final PublicacaoControl _publicacaoControl = PublicacaoControl();
  final NotificacaoControl _notificacaoControl = NotificacaoControl();

  late final Future<Usuario?> _usuarioFuture;
  late final Stream<List<Publicacao>> _publicacoesStream;
  late final Stream<int> _quantidadeNaoLidasStream;

  @override
  void initState() {
    super.initState();

    _usuarioFuture = _usuarioControl.buscarUsuarioAtual();
    _publicacoesStream = _publicacaoControl.acompanharPublicacoes();
    _quantidadeNaoLidasStream = _notificacaoControl.acompanharQuantidadeNaoLidas();
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

  Future<void> _selecionarDistancia(double? distancia) async {
    if (distancia == null) {
      setState(() {
        _distanciaMaximaKm = null;
        _coordenadasUsuario = null;
      });
      return;
    }

    if (_coordenadasUsuario != null) {
      setState(() {
        _distanciaMaximaKm = distancia;
      });
      return;
    }

    setState(() {
      _buscandoLocalizacao = true;
    });

    try {
      final coordenadas =
      await _localizacaoService.obterCoordenadasAtuais();

      if (!mounted) return;

      setState(() {
        _coordenadasUsuario = coordenadas;
        _distanciaMaximaKm = distancia;
      });
    } on LocalizacaoException catch (e) {
      if (!mounted) return;

      _aviso(e.mensagem);
    } catch (e, stackTrace) {
      debugPrint('Erro ao obter localização para o filtro: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _aviso('Não foi possível obter sua localização. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _buscandoLocalizacao = false;
        });
      }
    }
  }

  Widget _construirPainelDistancia() {
    if (!_painelDistanciaAberto) {
      return const SizedBox.shrink();
    }

    const distancias = <double?>[
      5,
      10,
      25,
      50,
      null,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD9CBB9),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distância máxima',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: distancias.map((distancia) {
                final selecionada =
                    _distanciaMaximaKm == distancia;

                final texto = distancia == null
                    ? 'Qualquer'
                    : '${distancia.toInt()} km';

                return ChoiceChip(
                  label: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selecionada
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: selecionada,
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.green,
                  side: BorderSide(
                    color: selecionada
                        ? AppColors.green
                        : const Color(0xFFD9CBB9),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: _buscandoLocalizacao
                      ? null
                      : (selecionado) {
                    if (selecionado) {
                      _selecionarDistancia(distancia);
                    }
                  },
                );
              }).toList(),
            ),
            if (_buscandoLocalizacao) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Obtendo sua localização...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesPublicacaoScreen(
                publicacao: publicacao,
              ),
            ),
          );
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
      AsyncSnapshot<List<Publicacao>> snapshot, {
        required bool tecladoAberto,
      }) {
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

    const ordemCategorias = [
      'Roupas',
      'Livros',
      'Móveis',
      'Calçados',
      'Utensílios',
      'Eletrônicos',
      'Outros',
    ];

    final categoriasDisponiveis = ordemCategorias
        .where(
          (categoria) => publicacoes.any(
            (publicacao) => publicacao.categoria == categoria,
      ),
    )
        .toList();

    final categorias = ['Todos', ...categoriasDisponiveis];

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

      final coordenadasPublicacao = publicacao.coordenadas;
      final coordenadasUsuario = _coordenadasUsuario;

      final correspondeDistancia =
          _distanciaMaximaKm == null ||
              (
                  coordenadasPublicacao != null &&
                      coordenadasUsuario != null &&
                      Geolocator.distanceBetween(
                        coordenadasUsuario.latitude,
                        coordenadasUsuario.longitude,
                        coordenadasPublicacao.latitude,
                        coordenadasPublicacao.longitude,
                      ) <=
                          _distanciaMaximaKm! * 1000
              );

      return correspondeCategoria &&
          correspondeBusca &&
          correspondeDistancia;
    }).toList();

    return Column(
      children: [
        if (!tecladoAberto) ...[
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
                  label: Text(
                    categoria,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selecionada ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: selecionada,
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selecionado) {
                    setState(() {
                      _categoria = selecionado ? categoria : 'Todos';
                    });
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
        ],
        Expanded(
          child: publicacoesFiltradas.isEmpty
              ? Center(
            child: Text(
              publicacoes.isEmpty
                  ? 'Ainda não há publicações disponíveis.'
                  : 'Nenhum item corresponde aos filtros selecionados.',
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
    final tecladoAberto = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!tecladoAberto)
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
                      StreamBuilder<int>(
                        stream: _quantidadeNaoLidasStream,
                        builder: (context, snapshot) {
                          final quantidade = snapshot.data ?? 0;

                          return IconButton(
                            tooltip: 'Notificações',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const NotificacoesScreen(),
                                ),
                              );
                            },
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                ),
                                if (quantidade > 0)
                                  Positioned(
                                    top: -6,
                                    right: -8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 17,
                                        minHeight: 17,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        quantidade > 99
                                            ? '99+'
                                            : '$quantidade',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_outlined),
                        tooltip: 'Sair',
                        onPressed: _sair,
                      ),
                    ],
                  ),
                ),
                if (!tecladoAberto)
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
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    tecladoAberto ? 8 : 16,
                    16,
                    tecladoAberto ? 8 : 16,
                  ),
                  child: TextField(
                    onChanged: (valor) {
                      setState(() {
                        _busca = valor;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar: jaqueta, livros, cadeira...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: _painelDistanciaAberto
                            ? 'Fechar filtros'
                            : 'Abrir filtros',
                        icon: const Icon(Icons.tune),
                        onPressed: () {
                          setState(() {
                            _painelDistanciaAberto = !_painelDistanciaAberto;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                _construirPainelDistancia(),
                Expanded(
                  child: StreamBuilder<List<Publicacao>>(
                    stream: _publicacoesStream,
                    builder: (context, snapshot) {
                      return _construirListaPublicacoes(
                        snapshot,
                        tecladoAberto: tecladoAberto,
                      );
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

          if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MinhasPublicacoesScreen(),
              ),
                  (route) => route.isFirst,
            );
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

          if (index == 3) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const ConversasScreen(),
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
