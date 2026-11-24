import 'package:flutter/material.dart';

import '../controller/notificacao_control.dart';
import '../controller/publicacao_control.dart';
import '../controller/chat_control.dart';
import '../model/notificacao.dart';
import '../theme/app_theme.dart';

import 'detalhes_publicacao_screen.dart';
import 'chat_screen.dart';
import 'interessados_screen.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() =>
      _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  final NotificacaoControl _notificacaoControl =
  NotificacaoControl();

  final PublicacaoControl _publicacaoControl =
  PublicacaoControl();

  final ChatControl _chatControl = ChatControl();

  late final Stream<List<Notificacao>> _notificacoesStream;

  @override
  void initState() {
    super.initState();

    _notificacoesStream =
        _notificacaoControl.acompanharNotificacoes();
  }

  void _aviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  IconData _obterIcone(String tipo) {
    switch (tipo) {
      case 'novo_interesse':
        return Icons.favorite_outline;

      case 'interessado_escolhido':
        return Icons.card_giftcard_outlined;

      case 'doacao_concluida':
        return Icons.check_circle_outline;

      case 'doacao_reaberta':
        return Icons.refresh_rounded;

      case 'nova_mensagem':
        return Icons.chat_bubble_outline;

      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Agora';

    final agora = DateTime.now();
    final dataLocal = data.toLocal();
    final diferenca = agora.difference(dataLocal);

    if (diferenca.isNegative || diferenca.inSeconds < 60) {
      return 'Agora';
    }

    if (diferenca.inHours < 1) {
      return '${diferenca.inMinutes} min';
    }

    if (diferenca.inHours < 24) {
      return '${diferenca.inHours} h';
    }

    final ontem = agora.subtract(const Duration(days: 1));

    if (ontem.year == dataLocal.year &&
        ontem.month == dataLocal.month &&
        ontem.day == dataLocal.day) {
      return 'Ontem';
    }

    final dia = dataLocal.day.toString().padLeft(2, '0');
    final mes = dataLocal.month.toString().padLeft(2, '0');

    return '$dia/$mes/${dataLocal.year}';
  }

  Future<void> _abrirNotificacao(Notificacao notificacao) async {
    try {
      if (!notificacao.lida) {
        await _notificacaoControl.marcarComoLida(
          notificacao.id,
        );
      }

      if (!mounted) return;

      final conversaId = notificacao.conversaId;

      if (conversaId != null && conversaId.trim().isNotEmpty) {
        final conversa = await _chatControl.buscarConversaPorId(
          conversaId,
        );

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversa: conversa,
            ),
          ),
        );

        return;
      }

      final publicacaoId = notificacao.publicacaoId;

      if (publicacaoId != null && publicacaoId.trim().isNotEmpty) {
        final publicacao =
        await _publicacaoControl.buscarPublicacaoPorId(
          publicacaoId,
        );

        if (!mounted) return;

        if (notificacao.tipo == 'novo_interesse') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InteressadosScreen(
                publicacao: publicacao,
              ),
            ),
          );
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalhesPublicacaoScreen(
              publicacao: publicacao,
            ),
          ),
        );

        return;
      }

      _aviso('Esta notificação não possui um destino disponível.');
    } catch (erro, stackTrace) {
      debugPrint('Erro ao abrir notificação: $erro');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _aviso(
        'Não foi possível abrir esta notificação. Tente novamente.',
      );
    }
  }

  Widget _construirCard(Notificacao notificacao) {
    final corFundo = notificacao.lida
        ? Colors.white
        : const Color(0xFFEAF3ED);

    return Container(
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3DDCF),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirNotificacao(notificacao),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFFD8E8DF),
                child: Icon(
                  _obterIcone(notificacao.tipo),
                  color: AppColors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacao.titulo,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2B24),
                            ),
                          ),
                        ),
                        if (!notificacao.lida)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notificacao.mensagem,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF34443C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatarData(notificacao.dataCriacao),
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
      ),
    );
  }

  Widget _construirLista(
      AsyncSnapshot<List<Notificacao>> snapshot,
      ) {
    if (snapshot.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível carregar suas notificações. '
                'Tente novamente.',
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

    final notificacoes = snapshot.data ?? [];

    if (notificacoes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 52,
                color: AppColors.muted,
              ),
              SizedBox(height: 12),
              Text(
                'Você ainda não possui notificações.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: notificacoes.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _construirCard(notificacoes[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.green,
        elevation: 0,
        title: const Text(
          'Notificações',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.green,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: StreamBuilder<List<Notificacao>>(
              stream: _notificacoesStream,
              builder: (context, snapshot) {
                return _construirLista(snapshot);
              },
            ),
          ),
        ),
      ),
    );
  }
}