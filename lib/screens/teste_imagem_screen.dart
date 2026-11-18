import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../widgets/botoes.dart';

class TesteImagemScreen extends StatefulWidget {
  const TesteImagemScreen({super.key});

  @override
  State<TesteImagemScreen> createState() => _TesteImagemScreenState();
}

class _TesteImagemScreenState extends State<TesteImagemScreen> {
  final ImagePicker _seletorImagem = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool _enviando = false;
  String? _urlImagem;
  XFile? _imagemSelecionada;
  String? _erro;

  Future<void> selecionarImagem() async {
    try {
      final imagem = await _seletorImagem.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagem == null) {
        return;
      }

      setState(() {
        _imagemSelecionada = imagem;
        _erro = null;
      });
    } catch (e) {
      setState(() {
        _erro = 'Não foi possível selecionar a imagem.';
      });
    }
  }

  Future<void> enviarImagem() async {
    if (_imagemSelecionada == null) {
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
      _urlImagem = null;
    });

    try {
      final url = await _cloudinaryService.enviarImagem(
        _imagemSelecionada!,
      );

      if (!mounted) return;

      setState(() {
        _urlImagem = url;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e is CloudinaryException
            ? e.mensagem
            : 'Não foi possível enviar a imagem.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de imagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imagemSelecionada != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagemSelecionada!.path),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 70,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: selecionarImagem,
              icon: const Icon(Icons.photo_library),
              label: const Text('Selecionar imagem'),
            ),

            if (_imagemSelecionada != null) ...[

              const SizedBox(height: 12),

              Botoes(
                _enviando ? 'Enviando...' : 'Enviar imagem',
                onPressed: _enviando ? null : enviarImagem,
              ),
            ],

            if (_enviando) ...[

              const SizedBox(height: 12),

              const CircularProgressIndicator(),
            ],

            if (_urlImagem != null) ...[

              const SizedBox(height: 16),

              const Text('Imagem enviada com sucesso!'),
              SelectableText(_urlImagem!),
            ],

            if (_erro != null) ...[

              const SizedBox(height: 12),

              Text(
                _erro!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
