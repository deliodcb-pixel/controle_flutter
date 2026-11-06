import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mediatech/main.dart';
import 'package:mediatech/services/api_service.dart';

http.Response _json(Object corps, int code) => http.Response(
      jsonEncode(corps),
      code,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

ApiService _service(http.Response Function() reponse) => ApiService(
      client: MockClient((_) async => reponse()),
      baseUrl: 'http://test',
    );

final _troisLivres = [
  {
    'id': 1,
    'titre': 'Le Petit Prince',
    'auteur': 'Saint-Exupery',
    'annee': 1943,
    'resume': 'Un pilote rencontre un petit garcon.',
    'disponible': true,
  },
  {
    'id': 2,
    'titre': 'Les Miserables',
    'auteur': 'Victor Hugo',
    'annee': 1862,
    'resume': 'Le destin de Jean Valjean.',
    'disponible': false,
  },
  {
    'id': 3,
    'titre': 'Candide',
    'auteur': 'Voltaire',
    'annee': 1759,
    'resume': 'Le jeune Candide parcourt le monde.',
    'disponible': true,
  },
];

Future<void> _reserverLePetitPrince(WidgetTester tester) async {
  await tester.tap(find.text('Le Petit Prince'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Réserver'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'Dupont');
  await tester.enterText(
    find.byType(TextFormField).at(1),
    'dupont@exemple.fr',
  );
  await tester.tap(find.text('Confirmer la réservation'));
}

ButtonStyleButton _boutonReserver(WidgetTester tester) =>
    tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Réserver'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );

void main() {
  testWidgets('le catalogue affiche le titre et un livre', (tester) async {
    await tester.pumpWidget(
      MediaTechApp(api: _service(() => _json(_troisLivres, 200))),
    );
    await tester.pumpAndSettle();

    expect(find.text('MediaTech'), findsOneWidget);
    expect(find.text('Le Petit Prince'), findsOneWidget);
  });

  testWidgets('une erreur serveur affiche un message et « Réessayer »',
      (tester) async {
    await tester.pumpWidget(
      MediaTechApp(api: _service(() => _json({'erreur': 'x'}, 500))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('réessayez plus tard'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('une liste vide affiche un message dédié', (tester) async {
    await tester.pumpWidget(
      MediaTechApp(api: _service(() => _json([], 200))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun livre dans le catalogue.'), findsOneWidget);
  });

  testWidgets('un appui sur un livre ouvre son détail', (tester) async {
    await tester.pumpWidget(
      MediaTechApp(api: _service(() => _json(_troisLivres, 200))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Le Petit Prince'));
    await tester.pumpAndSettle();

    expect(find.text('Année : 1943'), findsOneWidget);
  });

  testWidgets('une année ou un résumé absent a un texte de remplacement',
      (tester) async {
    await tester.pumpWidget(
      MediaTechApp(
        api: _service(
          () => _json([
            {
              'id': 4,
              'titre': 'Germinal',
              'auteur': 'Zola',
              'annee': null,
              'disponible': true,
            },
          ], 200),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Zola (année inconnue)'), findsOneWidget);

    await tester.tap(find.text('Germinal'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun résumé disponible.'), findsOneWidget);
  });

  testWidgets('une réservation confirmée revient au catalogue, livre emprunté',
      (tester) async {
    final api = ApiService(
      client: MockClient(
        (req) async => req.method == 'POST'
            ? _json({'id': 1, 'statut': 'confirmee'}, 201)
            : _json(_troisLivres, 200),
      ),
      baseUrl: 'http://test',
    );
    await tester.pumpWidget(MediaTechApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Emprunté'), findsOneWidget);

    await _reserverLePetitPrince(tester);
    await tester.pumpAndSettle();

    // Catalogue : confirmation, et ce livre s'ajoute à celui déjà emprunté.
    expect(find.text('MediaTech'), findsOneWidget);
    expect(find.textContaining('Réservation confirmée'), findsOneWidget);
    expect(find.text('Emprunté'), findsNWidgets(2));

    await tester.tap(find.text('Le Petit Prince'));
    await tester.pumpAndSettle();
    expect(_boutonReserver(tester).enabled, isFalse);
  });

  testWidgets('quitter le formulaire pendant l\'envoi laisse la fiche ouverte',
      (tester) async {
    final reponse = Completer<http.Response>();
    final api = ApiService(
      client: MockClient(
        (req) => req.method == 'POST'
            ? reponse.future
            : Future.value(_json(_troisLivres, 200)),
      ),
      baseUrl: 'http://test',
    );
    await tester.pumpWidget(MediaTechApp(api: api));
    await tester.pumpAndSettle();

    await _reserverLePetitPrince(tester);
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    reponse.complete(_json({'id': 1, 'statut': 'confirmee'}, 201));
    await tester.pumpAndSettle();

    expect(find.text('Année : 1943'), findsOneWidget);
    expect(find.text('Emprunté'), findsOneWidget);
    expect(_boutonReserver(tester).enabled, isFalse);
  });
}
