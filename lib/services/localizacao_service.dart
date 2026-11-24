import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocalizacaoException implements Exception {
  final String mensagem;

  LocalizacaoException(this.mensagem);

  @override
  String toString() => mensagem;
}

class CoordenadasLocalizacao {
  final double latitude;
  final double longitude;

  const CoordenadasLocalizacao({
    required this.latitude,
    required this.longitude,
  });
}

class LocalizacaoResultado {
  final String endereco;
  final double latitude;
  final double longitude;

  const LocalizacaoResultado({
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });
}

class LocalizacaoService {
  final Geocoding _geocoding = Geocoding();

  Future<Position> _obterPosicaoAtual() async {
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
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      throw LocalizacaoException(
        'A localização demorou demais. Tente novamente.',
      );
    }
  }

  Future<CoordenadasLocalizacao> obterCoordenadasAtuais() async {
    final posicao = await _obterPosicaoAtual();

    return CoordenadasLocalizacao(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
    );
  }

  Future<LocalizacaoResultado> obterLocalizacao() async {
    final posicao = await _obterPosicaoAtual();

    try {
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

      return LocalizacaoResultado(
        endereco: partes.toSet().join(', '),
        latitude: double.parse(
          posicao.latitude.toStringAsFixed(2),
        ),
        longitude: double.parse(
          posicao.longitude.toStringAsFixed(2),
        ),
      );
    } on TimeoutException {
      throw LocalizacaoException(
        'A localização demorou demais. Tente novamente.',
      );
    }
  }
}