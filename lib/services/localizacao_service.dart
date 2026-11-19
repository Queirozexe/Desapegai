import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocalizacaoException implements Exception {
  final String mensagem;

  LocalizacaoException(this.mensagem);

  @override
  String toString() => mensagem;
}

class LocalizacaoService {
  final Geocoding _geocoding = Geocoding();

  Future<String> obterLocalizacao() async {
    final servicoAtivado = await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivado) {
      throw LocalizacaoException(
        'Ative a localização do celular para continuar.',
      );
    }

    LocationPermission permissao =
    await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw LocalizacaoException(
        'Permissão de localização não concedida.',
      );
    }

    if (permissao == LocationPermission.deniedForever) {
      throw LocalizacaoException(
        'A permissão foi negada permanentemente. '
            'Ative-a nas configurações do aplicativo.',
      );
    }

    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final enderecos = await _geocoding.placemarkFromCoordinates(
        posicao.latitude,
        posicao.longitude,
      );

      if (enderecos.isEmpty) {
        throw LocalizacaoException(
          'Não foi possível identificar sua localização.',
        );
      }

      final endereco = enderecos.first;

      final bairro = endereco.subLocality;

      final cidade = endereco.locality?.isNotEmpty == true
          ? endereco.locality
          : endereco.subAdministrativeArea;

      final estado = endereco.administrativeArea;

      final partes = <String>[];

      if (bairro != null && bairro.isNotEmpty) {
        partes.add(bairro);
      }

      if (cidade != null && cidade.isNotEmpty) {
        partes.add(cidade);
      }

      if (estado != null && estado.isNotEmpty) {
        partes.add(estado);
      }

      if (partes.isEmpty) {
        throw LocalizacaoException(
          'Não foi possível identificar bairro, cidade ou estado.',
        );
      }

      return partes.toSet().join(', ');
    } on TimeoutException {
      throw LocalizacaoException(
        'A localização demorou demais. Tente novamente.',
      );
    }
  }
}
