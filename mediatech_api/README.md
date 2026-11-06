# API de simulation MediaTech – tutoriel d'installation

L'application MediaTech interroge une API fournie sous la forme d'un petit serveur Python, qui ne
demande l'installation d'aucun paquet. Il faut le lancer avant de tester l'application et le laisser
tourner pendant toute l'évaluation. Les données sont en mémoire : relancer le serveur les remet à zéro.

## Étape 1 – Vérifier que Python est installé

Ouvrez un terminal (Windows : touche Windows, tapez `cmd` ; Mac : application Terminal ;
Linux : Ctrl + Alt + T), puis tapez :

```bash
python3 --version
```

Sous Windows, tapez `py --version`. Le terminal doit afficher `Python 3.8` ou une version plus récente.
Si la commande est introuvable, installez Python depuis python.org ; sous Windows, cochez
« Add Python to PATH » pendant l'installation.

## Étape 2 – Récupérer les fichiers

Dézippez l'archive fournie. Le dossier `mediatech_api` contient `serveur.py` et ce `README.md`.

## Étape 3 – Se placer dans le dossier

Dans le terminal, allez dans `mediatech_api` :

```bash
cd chemin/vers/mediatech_api
```

- Si le chemin contient des espaces, mettez-le entre guillemets : `cd "Mon dossier/mediatech_api"`.
- Sur Mac, tapez `cd ` puis glissez le dossier dans la fenêtre du terminal.
- Sous Windows, ouvrez le dossier dans l'Explorateur, cliquez dans la barre d'adresse, tapez `cmd` et validez.

Vérifiez que vous êtes au bon endroit : `ls` (Mac, Linux) ou `dir` (Windows) doit afficher `serveur.py`.

## Étape 4 – Lancer le serveur

```bash
python3 serveur.py
```

Sous Windows : `py serveur.py`. Pour utiliser un autre port : `python3 serveur.py 9000`.
Le terminal affiche :

```text
API MediaTech (simulation) sur http://0.0.0.0:8000  -  Ctrl+C pour arrêter
```

Laissez ce terminal ouvert : le serveur ne tourne que tant qu'il reste ouvert.
Ouvrez un second terminal pour travailler avec Flutter.

## Étape 5 – Vérifier que l'API répond

Dans un navigateur, ouvrez `http://localhost:8000/api/livres` (et non `0.0.0.0`, qui n'est pas une
adresse à saisir). Vous devez voir la liste des 8 livres au format JSON. Chaque requête reçue ajoute
une ligne dans le terminal du serveur : gardez-le sous les yeux pendant vos tests.

En ligne de commande :

```bash
curl http://localhost:8000/api/livres
curl -X POST http://localhost:8000/api/reservations \
     -H "Content-Type: application/json" \
     -d '{"livreId":1,"nom":"Dupont","email":"dupont@exemple.fr"}'
```

## Étape 6 – Adresse utilisée par l'application

| Cible | Adresse de l'API |
| --- | --- |
| Chrome (web) | `http://localhost:8000` |
| Simulateur iOS | `http://localhost:8000` |
| Émulateur Android | `http://10.0.2.2:8000` |
| Téléphone réel | `http://IP-de-votre-poste:8000` (même réseau Wi-Fi) |

Le projet fourni choisit l'adresse tout seul selon la plateforme. Pour un téléphone réel ou un autre
port, lancez l'application avec :

```bash
flutter run --dart-define=API_URL=http://IP-de-votre-poste:8000
```

## Étape 7 – Arrêter, relancer

`Ctrl + C` arrête le serveur. Pour tester le comportement de l'application quand le serveur est
injoignable, arrêtez-le simplement, puis relancez-le.

## Délai simulé

Pour imiter un vrai réseau, le serveur met 0,5 s à renvoyer la liste des livres et 1,5 s à traiter une
réservation. C'est normal : l'indicateur de chargement de l'application doit alors rester visible un instant.

## Si ça ne marche pas

| Message ou symptôme | Cause et solution |
| --- | --- |
| `python3` ou `py` introuvable | Python n'est pas installé ou n'est pas dans le PATH : voir l'étape 1. |
| `can't open file … serveur.py` | Vous n'êtes pas dans le dossier `mediatech_api` : refaites l'étape 3 et vérifiez avec `ls` ou `dir`. |
| `Address already in use` | Le port 8000 est déjà utilisé (un ancien serveur tourne encore ?). Fermez-le, ou lancez `python3 serveur.py 9000` et utilisez le port 9000 dans l'adresse. |
| Le navigateur affiche « Connection refused » ou une erreur de proxy | Vérifiez que le serveur tourne et utilisez `localhost` ; essayez un autre navigateur, ou testez dans le terminal avec `curl --noproxy "*" http://localhost:8000/api/livres`. |
| Fenêtre du pare-feu Windows | Cliquez sur « Autoriser l'accès ». |
| L'application affiche « Impossible de joindre le serveur » | Le serveur est arrêté, ou l'adresse ne correspond pas à votre cible (étape 6). |

## Routes de l'API

| Méthode | Route | Réponses |
| --- | --- | --- |
| GET | `/api/livres` | 200, tableau JSON de 8 livres |
| GET | `/api/livres/{id}` | 200, objet JSON ; 404 si inconnu |
| POST | `/api/reservations` | 201 `{ "id": 1, "statut": "confirmee" }` ; 422 si données invalides ou livre indisponible ; 404 si le livre n'existe pas |

Corps attendu du POST (`Content-Type: application/json`) :

```json
{ "livreId": 1, "nom": "Dupont", "email": "dupont@exemple.fr" }
```
