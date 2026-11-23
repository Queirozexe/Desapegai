import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controller/chat_control.dart';
import '../controller/publicacao_control.dart';
import '../controller/denuncia_control.dart';
import '../model/conversa.dart';
import '../model/mensagem.dart';
import '../theme/app_theme.dart';
import '../widgets/input.dart';
import '../widgets/dialogo_denuncia.dart';
import 'detalhes_publicacao_screen.dart';

class ChatScreen extends StatefulWidget {
  final Conversa conversa;

  const ChatScreen({
    super.key,
    required this.conversa,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatControl _chatControl = ChatControl();
  final TextEditingController _mensagemController = TextEditingController();
  final PublicacaoControl _publicacaoControl = PublicacaoControl();
  final DenunciaControl _denunciaControl = DenunciaControl();

  late final Stream<List<Mensagem>> _mensagensStream;
  late final String _usuarioAtualId;

  bool _abrindoPublicacao = false;
  bool _enviando = false;
  bool _enviandoDenuncia = false;

  bool get _ehDoadorAtual =>
      _usuarioAtualId.isNotEmpty &&
          _usuarioAtualId == widget.conversa.doadorId;

  bool get _ehParticipanteAtual =>
      _usuarioAtualId.isNotEmpty &&
          (_ehDoadorAtual ||
              _usuarioAtualId == widget.conversa.interessadoId);

  @override
  void initState() {
    super.initState();

    _usuarioAtualId =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    _mensagensStream = _chatControl.acompanharMensagens(
      widget.conversa.id,
    );
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    super.dispose();
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

    return '${partes.first[0]}${partes.last[0]}'
        .toUpperCase();
  }

  String _formatarHorario(DateTime? data) {
    if (data == null) return 'Enviando...';

    final horario = data.toLocal();

    final hora = horario.hour.toString().padLeft(2, '0');
    final minuto = horario.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  Future<void> _abrirPublicacao() async {
    if (_abrindoPublicacao) return;

    setState(() {
      _abrindoPublicacao = true;
    });

    try {
      final publicacao = await _publicacaoControl.buscarPublicacaoPorId(
        widget.conversa.publicacaoId,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DetalhesPublicacaoScreen(
            publicacao: publicacao,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir a publicação. Ela pode estar indisponível.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _abrindoPublicacao = false;
        });
      }
    }
  }

  Future<void> _denunciarUsuario() async {
    if (_enviandoDenuncia || !_ehParticipanteAtual) return;

    final resultado = await DialogoDenuncia.mostrar(
      context: context,
      titulo: _ehDoadorAtual
          ? 'Denunciar interessado'
          : 'Denunciar doador',
      motivos: DenunciaControl.motivosUsuario,
    );

    if (!mounted || resultado == null) return;

    setState(() {
      _enviandoDenuncia = true;
    });

    try {
      await _denunciaControl.denunciarUsuario(
        conversaId: widget.conversa.id,
        motivo: resultado['motivo']!,
        descricao: resultado['descricao'] ?? '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denúncia enviada com sucesso.'),
        ),
      );
    } catch (erro, stackTrace) {
      debugPrint('Erro ao denunciar usuário: $erro');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível enviar a denúncia. Tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviandoDenuncia = false;
        });
      }
    }
  }


  Future<void> _enviarMensagem() async {
    final texto = _mensagemController.text.trim();

    if (texto.isEmpty || _enviando) return;

    setState(() {
      _enviando = true;
    });

    try {
      await _chatControl.enviarMensagem(
        conversaId: widget.conversa.id,
        texto: texto,
      );

      if (!mounted) return;

      _mensagemController.clear();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível enviar a mensagem. Tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  Widget _construirBalao(Mensagem mensagem) {
    final minhaMensagem =
        mensagem.remetenteId == _usuarioAtualId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: minhaMensagem
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: minhaMensagem
                    ? AppColors.green
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: minhaMensagem
                    ? null
                    : Border.all(
                  color: const Color(0xFFE3DDCF),
                ),
              ),
              child: Text(
                mensagem.texto,
                style: TextStyle(
                  color: minhaMensagem
                      ? Colors.white
                      : const Color(0xFF1B2B24),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _formatarHorario(mensagem.dataEnvio),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirMensagens(
      AsyncSnapshot<List<Mensagem>> snapshot,
      ) {
    if (snapshot.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível carregar as mensagens.',
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

    final mensagens = snapshot.data ?? [];

    if (mensagens.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Ainda não há mensagens. Envie uma mensagem para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: mensagens.length,
      itemBuilder: (context, index) {
        final mensagem =
        mensagens[mensagens.length - 1 - index];

        return _construirBalao(mensagem);
      },
    );
  }

  Widget _construirCampoMensagem() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE3DDCF),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.green,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              child: Input(
                '',
                'Escreva uma mensagem...',
                controller: _mensagemController,
                semRotulo: true,
                maxLength: 1000,
                mostrarContador: false,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _enviarMensagem(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: _enviando
                ? AppColors.muted
                : AppColors.green,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _enviando ? null : _enviarMensagem,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: _enviando
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.conversa.nomeOutroParticipante(
      _usuarioAtualId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE3DDCF),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.green,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFDDEFE3),
                    child: Text(
                      _gerarIniciais(nome),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
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
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2B24),
                                ),
                              ),
                            ),
                            if (_ehParticipanteAtual)
                              IconButton(
                                onPressed: _enviandoDenuncia ? null : _denunciarUsuario,
                                tooltip: _ehDoadorAtual
                                    ? 'Denunciar interessado'
                                    : 'Denunciar doador',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.flag_outlined,
                                  color: AppColors.muted,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        InkWell(
                          onTap: _abrindoPublicacao ? null : _abrirPublicacao,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.conversa.tituloPublicacao,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.green,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (_abrindoPublicacao)
                                  const SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: AppColors.green,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 13,
                                    color: AppColors.green,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFDDEFE3),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.green,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Não compartilhe senhas nem faça pagamentos.',
                      style: TextStyle(
                        color: Color(0xFF34443C),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Mensagem>>(
                stream: _mensagensStream,
                builder: (context, snapshot) {
                  return _construirMensagens(snapshot);
                },
              ),
            ),
            _construirCampoMensagem(),
          ],
        ),
      ),
    );
  }
}