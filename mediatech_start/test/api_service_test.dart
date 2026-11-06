import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mediatech/services/api_service.dart';

http.Response _json(Object corps, int code) => http.Response(
      jsonEncode(corps),
      code,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

ApiService _service(Future<http.Response> Function(http.Request) handler) =>
    ApiService(client: MockClient(handler), baseUrl: 'http://test');

void main() {
  test('fetchLivres convertit le JSON en objets Livre', () async {
    final api = _service((req) async {
      expect(req.method, 'GET');
      expect(req.url.path, '/api/livres');
      return _json([
        {'id': 1, 'titre': 'A', 'auteur': 'B', 'annee': 2000, 'disponible': true},
        {'id': 2, 'titre': 'C', 'auteur': 'D', 'annee': null, 'disponible': false},
      ], 200);
    });

    final livres = await api.fetchLivres();

    expect(livres, hasLength(2));
    expect(livres.first.titre, 'A');
    expect(livres.last.annee, isNull);
  });

  test('fetchLivres signale une erreur serveur (5xx)', () async {
    final api = _service((_) async => _json({'erreur': 'boom'}, 500));

    expect(api.fetchLivres(), throwsA(isA<ApiException>()));
  });

  test('reserver envoie un corps JSON avec les trois champs', () async {
    late http.Request recue;
    final api = _service((req) async {
      recue = req;
      return _json({'id': 1, 'statut': 'confirmee'}, 201);
    });

    await api.reserver(livreId: 3, nom: 'Dupont', email: 'dupont@exemple.fr');

    expect(recue.method, 'POST');
    expect(recue.url.path, '/api/reservations');
    expect(recue.headers['Content-Type'], contains('application/json'));
    expect(jsonDecode(recue.body), {
      'livreId': 3,
      'nom': 'Dupont',
      'email': 'dupont@exemple.fr',
    });
  });

  test('reserver remonte le message de l\'API en cas de 422', () async {
    final api = _service((_) async => _json({
          'erreur': 'Données invalides.',
          'details': {'email': 'L\'adresse e-mail est invalide.'},
        }, 422));

    expect(
      api.reserver(livreId: 1, nom: 'Dupont', email: 'abc'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', contains('e-mail')),
      ),
    );
  });

  test('une erreur réseau devient une ApiException compréhensible', () async {
    final api = _service((_) async => throw http.ClientException('hors ligne'));

    expect(
      api.fetchLivres(),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', contains('joindre')),
      ),
    );
  });
}
