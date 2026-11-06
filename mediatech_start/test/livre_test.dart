import 'package:flutter_test/flutter_test.dart';
import 'package:mediatech/models/livre.dart';

void main() {
  test('Livre.fromJson produit un objet correct quand resume est absent', () {
    final json = <String, dynamic>{
      'id': 1,
      'titre': 'Dune',
      'auteur': 'Frank Herbert',
      'annee': 1965,
      'disponible': true,
    };

    final livre = Livre.fromJson(json);

    expect(livre.id, 1);
    expect(livre.titre, 'Dune');
    expect(livre.auteur, 'Frank Herbert');
    expect(livre.annee, 1965);
    expect(livre.resume, isNull);
    expect(livre.disponible, isTrue);
  });
}
