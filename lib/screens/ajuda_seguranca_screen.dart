import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AjudaSegurancaScreen extends StatelessWidget {
  const AjudaSegurancaScreen({super.key});

  static const List<String> _passos = [
    'Publique o item com fotos e descrição',
    'Veja quem demonstrou interesse',
    'Escolha uma pessoa e combine a entrega',
    'Conclua a doação e avalie a experiência',
  ];

  static const List<_PerguntaFrequente> _perguntas = [
    _PerguntaFrequente(
      titulo: 'Como funciona uma doação?',
      resposta:
      'O doador publica o item. Quem tem interesse demonstra interesse '
          'pelo aplicativo, e o doador escolhe uma pessoa para receber. '
          'Depois, os dois podem conversar pelas mensagens para combinar '
          'a retirada ou entrega. Tudo é gratuito: o Desapegaí não vende '
          'produtos nem cobra taxas.',
    ),
    _PerguntaFrequente(
      titulo: 'Cuidados durante a conversa',
      resposta:
      'Utilize o chat do aplicativo para combinar os detalhes da doação. '
          'Não compartilhe senhas, códigos recebidos por SMS ou dados '
          'bancários. Desconfie de pedidos de dinheiro, depósitos ou '
          'pagamentos antecipados. A doação deve ser gratuita.',
    ),
    _PerguntaFrequente(
      titulo: 'Como combinar a retirada com segurança',
      resposta:
      'Prefira locais públicos e movimentados, durante o dia. Avise '
          'alguém de confiança sobre o encontro e, se possível, vá '
          'acompanhado. Evite compartilhar seu endereço residencial '
          'publicamente e confira o item antes de recebê-lo.',
    ),
    _PerguntaFrequente(
      titulo: 'E se o item precisar de transporte?',
      resposta:
      'Combine diretamente com a outra pessoa como será feita a '
          'retirada ou a entrega do item. O Desapegaí não organiza nem '
          'intermedeia o transporte. A doação do produto continua sendo '
          'gratuita e o aplicativo não cobra taxas.',
    ),
    _PerguntaFrequente(
      titulo: 'Como denunciar ou bloquear alguém?',
      resposta:
      'Você pode denunciar uma publicação pela tela de detalhes do '
          'item ou denunciar um usuário pela conversa, utilizando o '
          'ícone de bandeira. A denúncia é registrada no sistema. O '
          'bloqueio de usuários ainda está em desenvolvimento e será '
          'disponibilizado em uma próxima atualização.',
    ),
    _PerguntaFrequente(
      titulo: 'Privacidade e seus dados',
      resposta:
      'Utilizamos os dados informados no cadastro e no perfil para '
          'o funcionamento do aplicativo. Evite compartilhar senhas, '
          'documentos, endereço residencial ou outras informações '
          'pessoais nas descrições e mensagens. As coordenadas das '
          'publicações são armazenadas de forma aproximada para '
          'preservar a privacidade.',
    ),
  ];

  Widget _construirPassos() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doar em 4 passos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_passos.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _passos.length - 1 ? 0 : 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.gold,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF1B2B24),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _passos[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _construirPergunta(
      BuildContext context,
      _PerguntaFrequente pergunta, {
        required bool inicialmenteExpandida,
      }) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE3DDCF),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: inicialmenteExpandida,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          collapsedIconColor: AppColors.green,
          iconColor: AppColors.green,
          title: Text(
            pergunta.titulo,
            style: const TextStyle(
              color: Color(0xFF1B2B24),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                pergunta.resposta,
                style: const TextStyle(
                  color: Color(0xFF34443C),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ajuda e segurança',
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _construirPassos(),
                  const SizedBox(height: 12),
                  ...List.generate(_perguntas.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _perguntas.length - 1 ? 0 : 8,
                      ),
                      child: _construirPergunta(
                        context,
                        _perguntas[index],
                        inicialmenteExpandida: index == 0,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PerguntaFrequente {
  final String titulo;
  final String resposta;

  const _PerguntaFrequente({
    required this.titulo,
    required this.resposta,
  });
}