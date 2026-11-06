# MediaTech – application à corriger

Application mobile de la médiathèque (évaluation Flutter, BTS SIO 2 SLAM).
Elle a été écrite par un collègue qui a quitté l'équipe et **contient des anomalies**.
Elle compile, `flutter analyze` ne signale rien et les tests fournis passent : les anomalies
ne se découvrent qu'en **utilisant l'application** (écrans, formulaire, cas limites, serveur arrêté),
en regardant le terminal du serveur et la console de `flutter run`.
Votre mission (partie 3 du sujet) : la corriger sans la réécrire, puis rendre le rapport
`corrections.md` (une ligne par anomalie : fichier, symptôme, cause, correction).

Le projet contient le code Dart (`lib/`), des tests (`test/`) et la configuration ;
les dossiers de plateforme (`android/`, `ios/`, `web/`…) sont à générer une fois.
Des tests verts ne prouvent pas que l'application fonctionne : ils ne couvrent qu'une partie du
comportement.

## Mise en place (5 minutes)

1. Depuis le dossier `mediatech_start`, générez les dossiers de plateforme :

   ```bash
   flutter create . --project-name mediatech
   ```

   Cette commande ne remplace pas `lib/main.dart` ni `pubspec.yaml`.
   (Pour ne générer que certaines plateformes : `--platforms=web,ios`.)

2. Récupérez les dépendances et vérifiez l'état du projet :

   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```

   Si `flutter pub get` échoue avec une erreur réseau (socket error), le réseau bloque
   `pub.dev` ou impose un proxy : voir « Réseau avec proxy » plus bas.

3. Lancez l'API de test (voir `mediatech_api/`), puis l'application :

   ```bash
   flutter run -d chrome     # Chrome
   flutter run               # simulateur iOS ou émulateur Android déjà ouvert
   ```

## Adresse de l'API

| Cible | Adresse de base |
| --- | --- |
| Chrome (web) | `http://localhost:8000` |
| Simulateur iOS | `http://localhost:8000` |
| Émulateur Android | `http://10.0.2.2:8000` (et non `localhost`, qui désigne l'émulateur lui-même) |
| Téléphone réel | `http://IP-du-poste:8000` (même réseau Wi-Fi) |

## Réglage propre à Android

Autorisez le HTTP en clair pour l'API de test. Dans
`android/app/src/main/AndroidManifest.xml`, ajoutez l'attribut sur la balise `<application>` :

```xml
<application
    android:usesCleartextTraffic="true"
    ... >
```

Ajoutez aussi, avant `<application>`, l'accès réseau (utile hors mode debug) :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

En production, l'API devrait être servie en HTTPS et `usesCleartextTraffic` retiré.
Ce réglage est inutile sur Chrome et sur le simulateur iOS.

## Réseau avec proxy

Dart lit les variables d'environnement du terminal. Si votre réseau impose un proxy
(`scutil --proxy` sur Mac affiche son adresse et son port) :

```bash
export HTTPS_PROXY=http://ADRESSE:PORT
export HTTP_PROXY=http://ADRESSE:PORT
export NO_PROXY=localhost,127.0.0.1
flutter pub get
```

Après un premier `flutter pub get` réussi, les paquets sont en cache et
`flutter pub get --offline` fonctionne sans réseau.

## Dépendances déjà déclarées

| Paquet | Usage |
| --- | --- |
| `http` | Appels à l'API REST |
| `provider` | Gestion d'état (facultatif) |
| `flutter_lints` | Règles de qualité de code (`flutter analyze`) |
