#!/usr/bin/env python3
"""API de simulation MediaTech (évaluation Flutter, BTS SIO 2 SLAM).

Aucune dépendance : Python 3.8+ suffit.

    python3 serveur.py            # écoute sur http://0.0.0.0:8000
    python3 serveur.py 9000       # autre port

Routes :
    GET  /api/livres              -> 200, tableau JSON
    GET  /api/livres/{id}         -> 200, objet JSON ; 404 si inconnu
    POST /api/reservations        -> 201, {"id": ..., "statut": "confirmee"}
                                     422 si données invalides ou livre indisponible
                                     404 si le livre n'existe pas

Depuis l'émulateur Android, l'adresse du poste est http://10.0.2.2:8000.
Les données sont en mémoire : elles se réinitialisent à chaque redémarrage.

Le serveur répond avec un léger délai (voir DELAI_LISTE et DELAI_RESERVATION) pour simuler
un vrai réseau : sans lui, tout est instantané sur le poste et certains comportements
(indicateur de chargement, double clic) ne seraient pas observables.
"""

import json
import re
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# Latence simulée, en secondes.
DELAI_LISTE = 0.5          # GET /api/livres
DELAI_RESERVATION = 1.5    # POST /api/reservations

LIVRES = [
    {"id": 1, "titre": "Le Petit Prince", "auteur": "Antoine de Saint-Exupéry", "annee": 1943,
     "resume": "Un pilote échoué dans le désert rencontre un petit garçon venu d'une autre planète.",
     "disponible": True},
    {"id": 2, "titre": "Les Misérables", "auteur": "Victor Hugo", "annee": 1862,
     "resume": "Le destin de Jean Valjean, ancien forçat, dans la France du XIXe siècle.",
     "disponible": False},
    {"id": 3, "titre": "L'Étranger", "auteur": "Albert Camus", "annee": 1942,
     "resume": "Meursault, employé à Alger, est jugé pour un meurtre qu'il ne s'explique pas.",
     "disponible": True},
    {"id": 4, "titre": "Germinal", "auteur": "Émile Zola", "annee": 1885,
     "resume": None,  # résumé volontairement absent : teste la gestion des valeurs nulles
     "disponible": True},
    {"id": 5, "titre": "Fahrenheit 451", "auteur": "Ray Bradbury", "annee": None,
     "resume": "Dans un futur proche, les pompiers brûlent les livres au lieu d'éteindre les feux.",
     "disponible": True},
    {"id": 6, "titre": "Le Comte de Monte-Cristo", "auteur": "Alexandre Dumas", "annee": 1844,
     "resume": "Edmond Dantès, injustement emprisonné, prépare sa vengeance.",
     "disponible": False},
    {"id": 7, "titre": "Vendredi ou la Vie sauvage", "auteur": "Michel Tournier", "annee": 1971,
     "disponible": True},  # champ "resume" totalement absent
    {"id": 8, "titre": "Candide", "auteur": "Voltaire", "annee": 1759,
     "resume": "Le jeune Candide parcourt le monde et remet en cause l'optimisme de son maître Pangloss.",
     "disponible": True},
]

RESERVATIONS = []
EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


class Handler(BaseHTTPRequestHandler):
    server_version = "MediaTechSim/1.0"

    # --- utilitaires -------------------------------------------------
    def _envoyer(self, code, corps=None):
        donnees = b"" if corps is None else json.dumps(corps, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(donnees)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.end_headers()
        self.wfile.write(donnees)

    def log_message(self, fmt, *args):
        sys.stderr.write("[%s] %s\n" % (self.log_date_time_string(), fmt % args))

    # --- méthodes HTTP -----------------------------------------------
    def do_OPTIONS(self):
        self._envoyer(204)

    def do_GET(self):
        chemin = self.path.split("?")[0].rstrip("/")
        if chemin == "/api/livres":
            time.sleep(DELAI_LISTE)
            return self._envoyer(200, LIVRES)
        m = re.fullmatch(r"/api/livres/(\d+)", chemin)
        if m:
            livre = next((l for l in LIVRES if l["id"] == int(m.group(1))), None)
            if livre is None:
                return self._envoyer(404, {"erreur": "Livre introuvable."})
            return self._envoyer(200, livre)
        self._envoyer(404, {"erreur": "Route inconnue."})

    def do_POST(self):
        chemin = self.path.split("?")[0].rstrip("/")
        if chemin != "/api/reservations":
            return self._envoyer(404, {"erreur": "Route inconnue."})

        time.sleep(DELAI_RESERVATION)

        try:
            longueur = int(self.headers.get("Content-Length", 0))
            donnees = json.loads(self.rfile.read(longueur) or b"{}")
            if not isinstance(donnees, dict):
                raise ValueError
        except ValueError:
            return self._envoyer(422, {"erreur": "Corps JSON invalide.",
                                       "details": {"corps": "JSON attendu"}})

        erreurs = {}
        livre_id = donnees.get("livreId")
        nom = donnees.get("nom")
        email = donnees.get("email")

        if not isinstance(livre_id, int) or isinstance(livre_id, bool):
            erreurs["livreId"] = "Un entier est attendu."
        if not isinstance(nom, str) or not nom.strip():
            erreurs["nom"] = "Le nom est obligatoire."
        if not isinstance(email, str) or not EMAIL_RE.match(email.strip()):
            erreurs["email"] = "L'adresse e-mail est invalide."
        if erreurs:
            return self._envoyer(422, {"erreur": "Données invalides.", "details": erreurs})

        livre = next((l for l in LIVRES if l["id"] == livre_id), None)
        if livre is None:
            return self._envoyer(404, {"erreur": "Livre introuvable."})
        if not livre["disponible"]:
            return self._envoyer(422, {"erreur": "Données invalides.",
                                       "details": {"livreId": "Ce livre n'est pas disponible."}})

        reservation = {"id": len(RESERVATIONS) + 1, "statut": "confirmee"}
        RESERVATIONS.append({**reservation, "livreId": livre_id,
                             "nom": nom.strip(), "email": email.strip()})
        livre["disponible"] = False
        self._envoyer(201, reservation)


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    serveur = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    print("API MediaTech (simulation) sur http://0.0.0.0:%d  -  Ctrl+C pour arrêter" % port)
    try:
        serveur.serve_forever()
    except KeyboardInterrupt:
        print("\nArrêt.")


if __name__ == "__main__":
    main()
