PARTIE 4 : 

4.1

```text
lib/
    main.dart
    models/
        livre.dart
    screens/
        catalogue_screen.dart
        detail_screen.dart
        reservation_screen.dart
    services/
        api_config.dart
        api_service.dart
    widgets/
        disponibilite_chip.dart
        livre_tile.dart
```



4.2

1/ Trafic en clair : en HTTP, une personne sur le même réseau (exemple : WiFi publique) peut lire ou modifier les échanges, dont le jeton et l'adresse e-mail. Mesure : utiliser HTTPS  pour tous les échanges en production. Les adresses http:// de ApiConfig doivent rester réservées au développement.

2/Jeton volé : un pirate mal intentionné qui récupère le jeton peut agir à la place de l'adhérent. Mesure : donner au jeton une durée de vie courte et permettre au serveur de le révoquer, par exemple à la déconnexion.

3/Je stocke le jeton dans le stockage sécurisé du téléphone avec le paquet flutter_secure_storage. Il s'appuie sur le Keychain sur iOS et sur des clés protégées par le Keystore sur Android.
Je n'utilise pas un fichier de préférences classique (shared_preferences), car il n'est pas chiffré. Le jeton y serait en clair, donc lisible sur un téléphone rooté ou dans une sauvegarde non chiffrée.

4.1/Informer les personnes et respecter leurs droits (art. 13 et 15 à 17) : au moment de la saisie, la médiathèque indique qui traite l'adresse e-mail, dans quel but, pendant combien de temps et comment demander son accès, sa rectification ou son effacement.

4.2/Limiter la conservation (art. 5) : l'adresse e-mail sert uniquement à gérer la réservation. Elle est supprimée ou anonymisée après un délai défini.


4.3

Un test unitaire contrôle un petit morceau de code tout seul, comme une fonction ou une classe, sans passer par l'interface, alors qu'un test de widget affiche un composant dans un environnement simulé pour voir s'il s'affiche bien et réagit comme prévu. Un test d'intégration, lui, lance toute l'application sur un téléphone ou un émulateur et vérifie un parcours complet, comme le ferait un utilisateur.
