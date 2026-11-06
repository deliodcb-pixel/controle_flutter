import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/livre.dart';
import 'api_config.dart';

/// Erreur dont le message est lisible par l'utilisateur.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const _delaiMax = Duration(seconds: 10);

  Future<List<Livre>> fetchLivres() async {
    final reponse = await _envoyer(
      () => _client.get(Uri.parse('$_baseUrl/api/livres')),
    );
    final data = jsonDecode(reponse.body) as List<dynamic>;
    return data
        .map((j) => Livre.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> reserver({
    required int livreId,
    required String nom,
    required String email,
  }) async {
    await _envoyer(
      () => _client.post(
        Uri.parse('$_baseUrl/api/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'livreId': livreId, 'nom': nom, 'email': email}),
      ),
    );
  }

  /// Exécute la requête avec un délai maximal et traduit les échecs
  /// (réseau, délai, codes HTTP) en [ApiException].
  Future<http.Response> _envoyer(
    Future<http.Response> Function() requete,
  ) async {
    final http.Response reponse;
    try {
      reponse = await requete().timeout(_delaiMax);
    } on TimeoutException {
      throw const ApiException('Délai dépassé : le serveur ne répond pas.');
    } on http.ClientException {
      throw const ApiException(
        'Impossible de joindre le serveur. Vérifiez qu\'il est lancé.',
      );
    }

    final code = reponse.statusCode;
    if (code >= 200 && code < 300) return reponse;
    if (code == 404) {
      throw ApiException(_detail(reponse, 'Ressource introuvable.'));
    }
    if (code == 422) {
      throw ApiException(
        _detail(reponse, 'Données invalides, vérifiez le formulaire.'),
      );
    }
    if (code >= 500) {
      throw const ApiException(
        'Le serveur rencontre un problème, réessayez plus tard.',
      );
    }
    throw ApiException('Erreur inattendue ($code).');
  }

  /// Extrait le message de l'API (`details` ou `erreur`) s'il existe.
  String _detail(http.Response reponse, String parDefaut) {
    try {
      final corps = jsonDecode(reponse.body) as Map<String, dynamic>;
      final details = corps['details'];
      if (details is Map && details.isNotEmpty) {
        return details.values.join('\n');
      }
      return corps['erreur'] as String? ?? parDefaut;
    } catch (_) {
      return parDefaut;
    }
  }
}
