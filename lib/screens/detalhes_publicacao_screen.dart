import 'package:flutter/material.dart';

import '../model/publicacao.dart';
import '../theme/app_theme.dart';
import '../widgets/botoes.dart';

class DetalhesPublicacaoScreen extends StatefulWidget {
  final Publicacao publicacao;

  const DetalhesPublicacaoScreen({super.key, required this.publicacao});

  @override
  State<DetalhesPublicacaoScreen> createState() =>
      _DetalhesPublicacaoScreenState();
}

class _DetalhesPublicacaoScreenState extends State<DetalhesPublicacaoScreen> {
  int _paginaAtual = 0;
  bool _demonstrouInteresse = false;

  Publicacao get publicacao => widget.publicacao;

  void _aviso(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
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

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  Widget _imagemIndisponivel() {
    return Container(
      color: const Color(0xFFE8ECE9),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: AppColors.muted,
      ),
    );
  }

  Widget _construirGaleria() {
    if (publicacao.imagens.isEmpty) {
      return SizedBox(
        height: 300,
        width: double.infinity,
        child: _imagemIndisponivel(),
      );
    }

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: publicacao.imagens.length,
            onPageChanged: (pagina) {
              setState(() {
                _paginaAtual = pagina;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                publicacao.imagens[index],
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progresso) {
                  if (progresso == null) {
                    return child;
                  }

                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return _imagemIndisponivel();
                },
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_paginaAtual + 1} de ${publicacao.imagens.length} fotos',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirEtiqueta(
    String texto, {
    required Color corFundo,
    required Color corTexto,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: corTexto,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _construirDoador() {
    final nome =
        publicacao.nomeDoador.trim().isEmpty ? 'Doador' : publicacao.nomeDoador;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFD8E8DF),
            child: Text(
              _gerarIniciais(nome),
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DOADOR',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Participante da comunidade Desapegaí',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirOrientacaoSeguranca() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.green, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica de segurança',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Combine a retirada em um local seguro e evite '
                  'compartilhar informações pessoais desnecessárias. '
                  'O Desapegaí é uma plataforma de doações gratuitas.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirConteudo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _construirEtiqueta(
                publicacao.status == 'ativa' ? 'Disponível' : publicacao.status,
                corFundo: const Color(0xFFE4F2E8),
                corTexto: AppColors.green,
              ),
              _construirEtiqueta(
                publicacao.categoria,
                corFundo: const Color(0xFFFFF2D8),
                corTexto: const Color(0xFF87621B),
              ),
              _construirEtiqueta(
                publicacao.estadoConservacao,
                corFundo: const Color(0xFFECECEC),
                corTexto: Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            publicacao.titulo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.green,
                size: 18,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  publicacao.cidade,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Publicado em ${_formatarData(publicacao.dataCriacao)}',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          const Text(
            'Descrição',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            publicacao.descricao,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sobre o doador',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _construirDoador(),
          const SizedBox(height: 24),
          const Text(
            'Entrega e retirada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Por se tratar de uma doação gratuita, combine com o doador '
            'os detalhes e o local da retirada do item.',
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          _construirOrientacaoSeguranca(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _construirAcoes() {
    if (!_demonstrouInteresse) {
      return SizedBox(
        width: double.infinity,
        child: Botoes(
          'Tenho interesse',
          onPressed: () {
            setState(() {
              _demonstrouInteresse = true;
            });
          },
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _demonstrouInteresse = false;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.green,
              side: const BorderSide(color: AppColors.green),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancelar interesse'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Botoes(
            'Conversar',
            onPressed: () {
              _aviso(
                'A área de mensagens será implementada em uma próxima etapa.',
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
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black87,
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            onPressed: () {
              _aviso(
                'A opção de denunciar publicações será implementada '
                'em uma próxima etapa.',
              );
            },
            icon: const Icon(Icons.flag_outlined),
            color: Colors.black87,
            tooltip: 'Denunciar publicação',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_construirGaleria(), _construirConteudo()],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: _construirAcoes(),
        ),
      ),
    );
  }
}
