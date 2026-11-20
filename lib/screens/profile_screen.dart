import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../controller/usuario_control.dart';
import '../controller/sessao_control.dart';
import '../model/usuario.dart';
import 'edit_profile_screen.dart';
import 'cadastro_publicacao_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UsuarioControl _usuarioControl = UsuarioControl();
  final SessaoControl _sessaoControl = SessaoControl();

  late Future<Usuario?> _usuarioFuture;

  @override
  void initState() {
    super.initState();
    _usuarioFuture = _usuarioControl.buscarUsuarioAtual();
  }

  String _gerarIniciais(String nome) {
    final partes =
        nome
            .trim()
            .split(RegExp(r'\s+'))
            .where((parte) => parte.isNotEmpty)
            .toList();

    if (partes.isEmpty) {
      return '?';
    }

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first.substring(0, 1)}'
            '${partes.last.substring(0, 1)}'
        .toUpperCase();
  }

  void _aviso(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _editarPerfil(Usuario usuario) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(usuario: usuario),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {
        _usuarioFuture = _usuarioControl.buscarUsuarioAtual();
      });
    }
  }

  Future<void> _sair() async {
    try {
      await _sessaoControl.sair();

      if (!mounted) return;

      Navigator.of(context).popUntil(
            (route) => route.isFirst,
      );
    } catch (e, stackTrace) {
      debugPrint('Erro ao encerrar sessão: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _aviso('Não foi possível sair. Tente novamente.');
    }
  }


  Widget _buildEstatistica({required String valor, required String descricao}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valor,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcaoPerfil({
    required IconData icone,
    required String titulo,
    required VoidCallback onTap,
    String? etiqueta,
  }) {
    return ListTile(
      leading: Icon(icone),
      title: Text(titulo),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (etiqueta != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                etiqueta,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    'Perfil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FutureBuilder<Usuario?>(
                          future: _usuarioFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  'Não foi possível carregar seu perfil.',
                                ),
                              );
                            }

                            final usuario = snapshot.data;

                            if (usuario == null) {
                              return const Center(
                                child: Text('Perfil não encontrado.'),
                              );
                            }

                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 32,
                                          backgroundColor: AppColors.green,
                                          child: Text(
                                            _gerarIniciais(usuario.nome),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                usuario.nome,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                usuario.cidade,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.muted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    const Text(
                                      'E-MAIL',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.muted,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      usuario.email,
                                      style: const TextStyle(fontSize: 14),
                                    ),

                                    const SizedBox(height: 16),

                                    const Text(
                                      'SOBRE MIM',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.muted,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      usuario.sobreMim.trim().isEmpty
                                          ? 'Você ainda não adicionou uma descrição.'
                                          : usuario.sobreMim,
                                    ),

                                    const SizedBox(height: 18),

                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () => _editarPerfil(usuario),
                                        child: const Text('Editar perfil'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildEstatistica(
                                valor: '—',
                                descricao: 'doações feitas',
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: _buildEstatistica(
                                valor: '—',
                                descricao: 'itens recebidos',
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: _buildEstatistica(
                                valor: '—',
                                descricao: 'avaliação',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Card(
                          child: Column(
                            children: [
                              _buildOpcaoPerfil(
                                icone: Icons.history,
                                titulo: 'Histórico de doações',
                                onTap: () {
                                  _aviso('O histórico de doações será implementado em uma próxima etapa.');
                                },
                              ),

                              const Divider(height: 1, indent: 56),

                              _buildOpcaoPerfil(
                                icone: Icons.help_outline,
                                titulo: 'Ajuda e segurança',
                                onTap: () {
                                  _aviso('A área de ajuda e segurança será implementada em uma próxima etapa.');
                                },
                              ),

                              const Divider(height: 1, indent: 56),

                              _buildOpcaoPerfil(
                                icone: Icons.admin_panel_settings_outlined,
                                titulo: 'Painel administrativo',
                                etiqueta: 'Admin',
                                onTap: () {
                                  _aviso('O painel administrativo ainda não está disponível.');
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        OutlinedButton.icon(
                          onPressed: _sair,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sair da conta'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Suas informações são utilizadas exclusivamente para '
                                'o funcionamento do Desapegaí. Seus dados são protegidos '
                                'e não são compartilhados sem sua autorização.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 4,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
            return;
          }

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
            return;
          }

          _aviso('Esta funcionalidade será implementada em uma próxima etapa.');
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
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
