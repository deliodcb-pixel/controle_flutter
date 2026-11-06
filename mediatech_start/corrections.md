# Rapport de corrections – DUCHESNE-BRAJON Délio

Une ligne par anomalie corrigée. Soyez précis : une explication correcte vaut autant que la correction.

Exemple (sans rapport avec ce projet) :

| N° | Fichier | Symptôme observé | Cause | Correction apportée |
| --- | --- | --- | --- | --- |
| 0 | `lib/exemple.dart` | L'écran reste blanc au lancement | Le widget racine renvoie `Container()` sans enfant | Retourne `Scaffold(...)` avec le contenu |

À vous :

| N° | Fichier | Symptôme observé | Cause | Correction apportée |
| --- | ---    | ---              | ---   | ---                 |
| 1 | `lib/screens/catalogue_screen.dart` | Le dernier livre du catalogue (« Candide ») n'apparaît jamais dans la liste | `itemCount: _livres.length - 1` fait construire un élément de moins que la liste n'en contient | `itemCount: _livres.length` |
| 2 | `lib/screens/catalogue_screen.dart` | Chaque actualisation ajoute les livres à la suite : la liste se duplique | `_livres = [..._livres, ...livres]` concatène la réponse à l'ancienne liste au lieu de la remplacer | `_livres = livres;` |
| 3 | `lib/screens/catalogue_screen.dart` | Si l'actualisation échoue (serveur arrêté), la liste disparaît au profit de l'écran d'erreur et aucune SnackBar ne s'affiche | `_signalerErreur` vide `_livres` juste avant de tester `_livres.isNotEmpty` : la liste est perdue et le test est toujours faux | Suppression de `_livres = [];` : la liste reste affichée et la SnackBar prévient de l'erreur |
| 4 | `lib/widgets/livre_tile.dart` | « Fahrenheit 451 » s'affiche avec « Ray Bradbury (0) » dans la liste | `livre.annee ?? 0` remplace l'année `null` par 0, présenté comme une vraie année | `'${livre.auteur} (${livre.annee ?? 'année inconnue'})'` |
| 5 | `lib/screens/detail_screen.dart` | La fiche affiche « Résumé : null » pour « Germinal » (résumé `null`) et « Vendredi ou la Vie sauvage » (champ absent) | `livre.resume` est de type `String?` et inséré dans le texte sans valeur de remplacement | Sans résumé, la fiche affiche « Aucun résumé disponible. » ; sinon `Résumé : ...` |
| 6 | `lib/screens/detail_screen.dart` | « Réserver » est grisé sur les livres disponibles et actif sur les livres empruntés | Condition inversée : `!livre.disponible` active le bouton quand le livre n'est pas disponible | `onPressed: livre.disponible ? ... : null` |
| 7 | `lib/screens/reservation_screen.dart` | Des adresses valides sont refusées : `jean.dupont@exemple.fr`, `dupont2@exemple.fr`, `Dupont@Exemple.fr` | La regex `^[a-z]+@[a-z]+\.[a-z]+$` n'accepte que des minuscules, sans chiffre, point ni tiret dans chaque partie | Même règle que le serveur : `^[^@\s]+@[^@\s]+\.[^@\s]+$` |
| 8 | `lib/screens/reservation_screen.dart` | Un nom composé uniquement d'espaces passe la validation ; il part vide et le serveur répond 422 | `_validerNom` teste `valeur.isEmpty` sans `trim()`, alors que l'envoi applique `trim()` au nom | Test de `valeur.trim().isEmpty` : l'erreur s'affiche sous le champ, sans appel au serveur |
| 9 | `lib/screens/reservation_screen.dart` | Le nom et l'e-mail du client s'affichent dans la console de `flutter run` à chaque réservation | Un `debugPrint` écrit des données personnelles dans les logs (risque de fuite, à éviter au regard du RGPD) | Suppression du `debugPrint` |
|10 | `lib/screens/reservation_screen.dart` | Le mauvais livre est réservé (Germinal, id 4 → Fahrenheit 451, id 5), ou le serveur répond 422 (livre suivant emprunté) ou 404 (Candide, id 8 → id 9 inexistant) | `livreId: widget.livre.id + 1` envoie l'identifiant du livre suivant | `livreId: widget.livre.id` |
|11 | `lib/screens/reservation_screen.dart` | La confirmation cite l'auteur au lieu du livre : « Réservation confirmée pour « Voltaire » » | Le message utilise `widget.livre.auteur` | Remplacement par `widget.livre.titre` |
|12 | `lib/screens/reservation_screen.dart` | Après une erreur (serveur arrêté, 422), le bouton reste en chargement et « Confirmer la réservation » ne réapparaît pas | La branche `on ApiException` affiche l'erreur mais ne remet pas `_envoi` à `false` | Ajout de `_envoi = false;` dans ce `setState` |
|13 | `lib/screens/reservation_screen.dart` | Un double clic envoie 2 réservations (2 POST dans le terminal du serveur) | Le bouton reste actif pendant l'envoi : chaque clic relance `_envoyer`, donc une requête de plus | `onPressed: _envoi ? null : _envoyer` désactive le bouton pendant l'envoi |
|14 | `lib/screens/reservation_screen.dart` | Après une réservation confirmée, l'application revient à la fiche du livre au lieu du catalogue | `navigateur.pop()` ne ferme que le formulaire | `navigateur.popUntil((r) => r.isFirst)` revient au catalogue |
|15 | `lib/services/api_service.dart` | Les erreurs de l'API s'affichent brutes : `{erreur: Données invalides., details: {...}}` | `_detail` renvoie `corps.toString()` (tout le JSON) au lieu d'extraire le message annoncé par son commentaire | Renvoie les valeurs de `details` si elles existent, sinon `erreur`, sinon le message par défaut |


(Ajoutez autant de lignes que nécessaire.)

## État final

- `flutter analyze` : aucun problème détecté .
- `flutter test` : les 13 tests passent, 9 fournis et 4 ajoutés 
- Éventuelles anomalies repérées mais non corrigées, et pourquoi :
  - Si l'on quitte le formulaire pendant l'envoi et que la réservation échoue, aucun message n'apparaît : le cas est rare et demanderait de revoir l'affichage des erreurs de cet écran.
  - La touche Entrée dans le champ e-mail ne valide pas le formulaire : c'est une amélioration d'ergonomie, le bouton de confirmation fonctionne.
  - Le `http.Client` de `ApiService` n'est jamais fermé : le service vit aussi longtemps que l'application, sans effet visible.



Hors tableau car non exigé par le comportement attendu : un livre réservé passe à « Emprunté » (avec une modification de mediatech_api/serveur.py)
