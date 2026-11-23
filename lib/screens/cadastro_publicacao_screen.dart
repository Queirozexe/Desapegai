import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/input.dart';
import '../widgets/botoes.dart';
import '../controller/publicacao_control.dart';
import '../model/publicacao.dart';
import '../theme/app_theme.dart';
import '../services/localizacao_service.dart';
import '../services/cloudinary_service.dart';
import 'profile_screen.dart';
import 'minhas_publicacoes_screen.dart';
import 'conversas_screen.dart';

class CadastroPublicacaoScreen extends StatefulWidget {
  final Publicacao? publicacao;

  const CadastroPublicacaoScreen({
    super.key,
    this.publicacao,
  });

  @override
  State<CadastroPublicacaoScreen> createState() =>
      _CadastroPublicacaoScreenState();
}

class _CadastroPublicacaoScreenState
    extends State<CadastroPublicacaoScreen> {
  static const int _limiteImagens = 3;

  final _formKey = GlobalKey<FormState>();
  final _imagensFieldKey = GlobalKey<FormFieldState<List<XFile>>>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cidadeController = TextEditingController();

  final LocalizacaoService _localizacaoService = LocalizacaoService();
  final ImagePicker _imagePicker = ImagePicker();
  final PublicacaoControl _publicacaoControl = PublicacaoControl();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  final List<XFile> _imagensSelecionadas = [];
  final List<String> _imagensExistentes = [];

  bool get _modoEdicao => widget.publicacao != null;

  int get _totalImagens =>
      _imagensExistentes.length + _imagensSelecionadas.length;

  String? _categoria;
  String? _estadoConservacao;

  bool _buscandoLocalizacao = false;
  bool _salvando = false;

  final List<String> _categorias = [
    'Roupas',
    'Livros',
    'Móveis',
    'Calçados',
    'Utensílios',
    'Eletrônicos',
    'Outros',
  ];

  final List<String> _estadosConservacao = [
    'Novo',
    'Seminovo',
    'Bom estado',
    'Estado razoável',
    'Para Retirada de Peças / Com Defeito',
  ];

  Future<void> _preencherLocalizacao() async {
    setState(() {
      _buscandoLocalizacao = true;
    });

    try {
      final localizacao =
      await _localizacaoService.obterLocalizacao();

      if (!mounted) return;

      _cidadeController.text = localizacao;
    } on LocalizacaoException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.mensagem),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível obter sua localização.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _buscandoLocalizacao = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final publicacao = widget.publicacao;

    if (publicacao != null) {
      _tituloController.text = publicacao.titulo;
      _descricaoController.text = publicacao.descricao;
      _cidadeController.text = publicacao.cidade;

      _categoria = publicacao.categoria;
      _estadoConservacao = publicacao.estadoConservacao;

      _imagensExistentes.addAll(publicacao.imagens);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagens() async {
    if (_totalImagens >= _limiteImagens) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você já atingiu o limite de 3 imagens.'),
        ),
      );
      return;
    }

    final imagens = await _imagePicker.pickMultiImage(
      imageQuality: 80,
    );

    if (imagens.isEmpty || !mounted) return;

    final vagasDisponiveis = _limiteImagens - _totalImagens;
    final novasImagens = imagens.take(vagasDisponiveis).toList();

    setState(() {
      _imagensSelecionadas.addAll(novasImagens);
    });

    _imagensFieldKey.currentState?.didChange(
      List<XFile>.from(_imagensSelecionadas),
    );

    if (imagens.length > vagasDisponiveis) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você pode selecionar no máximo 3 imagens.'),
        ),
      );
    }
  }

  void _removerImagemExistente(int indice) {
    setState(() {
      _imagensExistentes.removeAt(indice);
    });

    _imagensFieldKey.currentState?.didChange(
      List<XFile>.from(_imagensSelecionadas),
    );
  }

  void _removerImagem(int indice) {
    setState(() {
      _imagensSelecionadas.removeAt(indice);
    });

    _imagensFieldKey.currentState?.didChange(
      List<XFile>.from(_imagensSelecionadas),
    );
  }

  Widget _construirAreaImagens() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fotos',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$_totalImagens/$_limiteImagens',
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_totalImagens == 0)
          InkWell(
            onTap: _selecionarImagens,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFBDBDBD),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: Color(0xFF777777),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicionar fotos do item',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Você pode adicionar até 3 fotos',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < _imagensExistentes.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imagensExistentes[i],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image_outlined),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removerImagemExistente(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              for (int i = 0; i < _imagensSelecionadas.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_imagensSelecionadas[i].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removerImagem(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_totalImagens < _limiteImagens)
                InkWell(
                  onTap: _selecionarImagens,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFBDBDBD),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      size: 28,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _cadastrarPublicacao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar autenticado para doar.'),
        ),
      );
      return;
    }

    if (_modoEdicao && widget.publicacao?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar a publicação.'),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final urlsImagens = List<String>.from(_imagensExistentes);

      for (final imagem in _imagensSelecionadas) {
        final url = await _cloudinaryService.enviarImagem(imagem);
        urlsImagens.add(url);
      }

      if (_modoEdicao) {
        await _publicacaoControl.atualizarPublicacao(
          publicacaoId: widget.publicacao!.id!,
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          categoria: _categoria!,
          estadoConservacao: _estadoConservacao!,
          cidade: _cidadeController.text.trim(),
          imagens: urlsImagens,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicação atualizada com sucesso!'),
          ),
        );

        Navigator.pop(context);
      } else {
        final publicacao = Publicacao(
          usuarioId: usuario.uid,
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          categoria: _categoria!,
          estadoConservacao: _estadoConservacao!,
          cidade: _cidadeController.text.trim(),
          dataCriacao: DateTime.now(),
          imagens: urlsImagens,
        );

        await _publicacaoControl.cadastrarPublicacao(publicacao);

        if (!mounted) return;

        _tituloController.clear();
        _descricaoController.clear();
        _cidadeController.clear();

        _formKey.currentState?.reset();

        setState(() {
          _imagensSelecionadas.clear();
          _categoria = null;
          _estadoConservacao = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicação cadastrada com sucesso!'),
          ),
        );
      }
    } on CloudinaryException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.mensagem),
        ),
      );
    } on FirebaseException catch (e) {
      debugPrint('Erro do Firebase: ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modoEdicao
                ? 'Não foi possível atualizar a publicação.'
                : 'Não foi possível salvar a publicação.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao salvar publicação: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modoEdicao
                ? 'Ocorreu um erro ao atualizar a publicação.'
                : 'Ocorreu um erro ao cadastrar a publicação.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _modoEdicao ? 'Editar publicação' : 'Doar um item',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Text(
                _modoEdicao
                    ? 'Atualize as informações da sua publicação.'
                    : 'Quanto mais detalhes, mais fácil de encontrar quem precisa.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF777777),
                ),
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormField<List<XFile>>(
                key: _imagensFieldKey,
                initialValue: const [],
                validator: (valor) {
                  if (_totalImagens == 0) {
                    return 'Adicione pelo menos uma foto do item.';
                  }

                  return null;
                },
                builder: (campo) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirAreaImagens(),
                      if (campo.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            campo.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              Input(
                'Título',
                'Ex.: Jaqueta jeans infantil',
                controller: _tituloController,
                labelExterno: true,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o título do item.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Input(
                'Descrição',
                'Tamanho, medidas, detalhes de uso, o que acompanha...',
                controller: _descricaoController,
                maxLines: 3,
                labelExterno: true,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe a descrição do item.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              FormField<String>(
                initialValue: _categoria,
                validator: (valor) {
                  if (valor == null) {
                    return 'Selecione uma categoria.';
                  }
                  return null;
                },
                builder: (campo) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categoria',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categorias.map((categoria) {
                          return ChoiceChip(
                            label: Text(
                              categoria,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _categoria == categoria
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: _categoria == categoria,
                            showCheckmark: false,
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selecionado) {
                              setState(() {
                                _categoria = selecionado ? categoria : null;
                              });
                              campo.didChange(selecionado ? categoria : null);
                            },
                          );
                        }).toList(),
                      ),
                      if (campo.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            campo.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              FormField<String>(
                initialValue: _estadoConservacao,
                validator: (valor) {
                  if (valor == null) {
                    return 'Selecione o estado de conservação.';
                  }
                  return null;
                },
                builder: (campo) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estado de conservação',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _estadosConservacao.map((estado) {
                          return ChoiceChip(
                            label: Text(
                              estado,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: _estadoConservacao == estado
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: _estadoConservacao == estado,
                            showCheckmark: false,
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selecionado) {
                              setState(() {
                                _estadoConservacao = selecionado ? estado : null;
                              });
                              campo.didChange(selecionado ? estado : null);
                            },
                          );
                        }).toList(),
                      ),
                      if (campo.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            campo.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Input(
                          'Localização para retirada',
                          'Bairro e cidade',
                          controller: _cidadeController,
                          labelExterno: true,
                          maxLines: 2,
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Informe o bairro e a cidade.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 56,
                        width: 56,
                        child: IconButton.filled(
                          onPressed: _buscandoLocalizacao
                              ? null
                              : _preencherLocalizacao,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _buscandoLocalizacao
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mostramos só o bairro para os interessados. O endereço exato você combina na conversa.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF777777),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Botoes(
                _salvando
                    ? (_modoEdicao ? 'Salvando...' : 'Cadastrando...')
                    : (_modoEdicao ? 'Salvar alterações' : 'Cadastrar publicação'),
                onPressed: _salvando ? null : _cadastrarPublicacao,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Esta funcionalidade será implementada em uma próxima etapa.',
              ),
            ),
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
