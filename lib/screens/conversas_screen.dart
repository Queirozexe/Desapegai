import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controller/chat_control.dart';
import '../model/conversa.dart';
import '../theme/app_theme.dart';

import 'home_screen.dart';
import 'minhas_publicacoes_screen.dart';
import 'cadastro_publicacao_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class ConversasScreen extends StatefulWidget {
  const ConversasScreen({super.key});

  @override
  State<ConversasScreen> createState() => _ConversasScreenState();
}

class _ConversasScreenState extends State<ConversasScreen> {
  final ChatControl _chatControl = ChatControl();

  late final Stream<List<Conversa>> _conversasStream;

  @override
  void initState() {
    super.initState();
    _conversasStream = _chatControl.acompanharConversas();
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
    if (data == null) return 'Agora';

    final diferenca = DateTime.now().difference(data);

    if (diferenca.isNegative ||
        diferenca.inSeconds < 60) {
      return 'Agora';
    }

    if (diferenca.inHours < 1) {
      return '${diferenca.inMinutes} min';
    }

    if (diferenca.inHours < 24) {
      return '${diferenca.inHours} h';
    }

    if (diferenca.inHours < 48) {
      return 'Ontem';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  void _abrirConversa(Conversa conversa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversa: conversa,
        ),
      ),
    );
  }

  Widget _construirCard(Conversa conversa, String usuarioAtualId) {
    final nome = conversa.nomeOutroParticipante(usuarioAtualId);

    final data = conversa.dataUltimaMensagem ??
        conversa.dataCriacao;

    final mensagem = conversa.ultimaMensagem.trim();

    final previa = mensagem.isEmpty
        ? 'Conversa iniciada. Envie uma mensagem.'
        : '${conversa.ultimaMensagemRemetenteId == usuarioAtualId ? 'Você: ' : ''}$mensagem';

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3DDCF),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _abrirConversa(conversa),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFDDEFE3),
                child: Text(
                  _gerarIniciais(nome),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2B24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatarData(data),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conversa.tituloPublicacao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      previa,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF34443C),
                      ),
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

  Widget _construirLista(AsyncSnapshot<List<Conversa>> snapshot) {
    if (snapshot.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível carregar suas conversas. Tente novamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.green,
        ),
      );
    }

    final conversas = snapshot.data ?? [];

    if (conversas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Nenhuma conversa ainda. Demonstre interesse em um item para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.muted,
            ),
          ),
        ),
      );
    }

    final usuarioAtualId =
        FirebaseAuth.instance.currentUser?.uid;

    if (usuarioAtualId == null) {
      return const Center(
        child: Text('Usuário não autenticado.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: conversas.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _construirCard(
          conversas[index],
          usuarioAtualId,
        );
      },
    );
  }

  void _navegar(int index) {
    if (index == 3) return;

    Widget tela;

    if (index == 0) {
      tela = const HomeScreen();
    } else if (index == 1) {
      tela = const MinhasPublicacoesScreen();
    } else if (index == 2) {
      tela = const CadastroPublicacaoScreen();
    } else {
      tela = const ProfileScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => tela,
      ),
          (route) => route.isFirst,
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
                  padding: EdgeInsets.fromLTRB(20, 24, 16, 8),
                  child: Text(
                    'Mensagens',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Text(
                    'Combine retirada e entrega com quem doa ou recebe.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Conversa>>(
                    stream: _conversasStream,
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
        selectedIndex: 3,
        onDestinationSelected: _navegar,
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
            selectedIcon: Icon(Icons.chat_bubble),
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