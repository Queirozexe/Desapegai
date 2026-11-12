import 'package:flutter/material.dart';
import 'package:desapegai/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen ({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _busca = '';
  String _categoria = 'Todos';

  final List<String> _categorias = [
    'Todos',
    'Roupas',
    'Moveis',
    'Utensílios',
    'Calçados',
    'Outros',
  ];

  final List<Map<String, String>> _itens = [
    {
      'titulo': 'Jaqueta jeans infantil',
      'categoria': 'Roupas',
      'estado': 'Ótimo estado',
      'local': 'Centro',
      'distancia': '800 m',
    },
    {
      'titulo': 'Lote com 6 livros de ficção',
      'categoria': 'Livros',
      'estado': 'Ótimo estado',
      'local': 'Vila Barth',
      'distancia': '1,2 km',
    },
    {
      'titulo': 'Cadeira de escritório',
      'categoria': 'Móveis',
      'estado': 'Bom estado',
      'local': 'Vila Rio Branco',
      'distancia': '2,8 km',
    },
    {
      'titulo': 'Liquidificador 2 velocidades',
      'categoria': 'Utensílios',
      'estado': 'Funcionando',
      'local': 'Jardim Marabá',
      'distancia': '3,5 km',
    },
    {
      'titulo': 'Berço de madeira',
      'categoria': 'Móveis',
      'estado': 'Bom estado',
      'local': 'Centro',
      'distancia': '4,1 km',
    },
  ];
  void _aviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }
  @override
  Widget build(BuildContext context) {
    final itensFiltrados = _itens.where((item) {
      final correspondeCategoria =
          _categoria == 'Todos' ||
              item['categoria'] == _categoria;

      final termo = _busca.trim().toLowerCase();

      final correspondeBusca =
          termo.isEmpty ||
              item['titulo']!.toLowerCase().contains(termo) ||
              item['categoria']!.toLowerCase().contains(termo) ||
              item['local']!.toLowerCase().contains(termo);

      return correspondeCategoria && correspondeBusca;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 12, 16, 8,
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
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                                (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Localização demos
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Itapetininga, SP · localização exemplo',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
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
                ),

                // Campo de busca
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (valor) {
                      setState(() {
                        _busca = valor;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Buscar jaqueta, livros, cadeira...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),

                // Categorias
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categorias.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final categoria = _categorias[index];
                      final selecionada =
                          _categoria == categoria;

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

                // Quantidade de resultados
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${itensFiltrados.length} itens disponíveis',
                    style: const TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                ),

                // Lista de publicações
                Expanded(
                  child: itensFiltrados.isEmpty
                      ? const Center(
                    child: Text(
                      'Nenhum item encontrado.',
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: itensFiltrados.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = itensFiltrados[index];

                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius:
                          BorderRadius.circular(12),
                          onTap: () => _aviso(
                            'Detalhes do item serão implementados depois.',
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD8E8DF,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 32,
                                    color: AppColors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['titulo']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${item['categoria']} · ${item['estado']}',
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
                                              '${item['local']} · ${item['distancia']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Navegação inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index != 0) {
            _aviso(
              'próxima etapa.',
            );
          }
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
