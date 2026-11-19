
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryException implements Exception {
  final String mensagem;

  CloudinaryException(this.mensagem);

  @override
  String toString() => mensagem;
}

class CloudinaryService {
  static const String _cloudName = 'air8sxrq';
  static const String _uploadPreset = 'desapegai_publicacoes';

  static const int _tamanhoMaximo = 5 * 1024 * 1024;

  static const List<String> _formatosPermitidos = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  Future<String> enviarImagem(XFile imagem) async {
    try {
      final tamanho = await imagem.length();

      if (tamanho == 0) {
        throw CloudinaryException('O arquivo está vazio.');
      }

      if (tamanho > _tamanhoMaximo) {
        throw CloudinaryException(
          'A imagem deve ter no máximo 5 MB.',
        );
      }

      final extensao = imagem.name.split('.').last.toLowerCase();

      if (!_formatosPermitidos.contains(extensao)) {
        throw CloudinaryException(
          'Formato não permitido. Utilize JPG, PNG ou WebP.',
        );
      }

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final requisicao = http.MultipartRequest('POST', url);

      requisicao.fields['upload_preset'] = _uploadPreset;

      requisicao.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagem.path,
        ),
      );

      final resposta = await requisicao.send().timeout(
        const Duration(seconds: 30),
      );

      final corpoResposta = await resposta.stream.bytesToString().timeout(
        const Duration(seconds: 30),
      );

      final dados = jsonDecode(corpoResposta);

      if (resposta.statusCode < 200 ||
          resposta.statusCode >= 300) {
        String? mensagemApi;

        if (dados is Map) {
          final erro = dados['error'];

          if (erro is Map) {
            mensagemApi = erro['message']?.toString();
          }
        }

        throw CloudinaryException(
          mensagemApi ??
              'O Cloudinary retornou o erro HTTP ${resposta.statusCode}.',
        );
      }

      if (dados is! Map || dados['secure_url'] is! String) {
        throw CloudinaryException(
          'O Cloudinary não retornou o endereço da imagem.',
        );
      }

      return dados['secure_url'] as String;
    } on CloudinaryException {
      rethrow;
    } on SocketException {
      throw CloudinaryException(
        'Sem conexão com a internet. Verifique sua rede.',
      );
    } on TimeoutException {
      throw CloudinaryException(
        'O envio demorou demais. Tente novamente.',
      );
    } on http.ClientException {
      throw CloudinaryException(
        'Não foi possível estabelecer comunicação com o Cloudinary.',
      );
    } on FormatException {
      throw CloudinaryException(
        'O servidor retornou uma resposta inválida.',
      );
    }
  }
}
