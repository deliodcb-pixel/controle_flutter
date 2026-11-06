class Livre {
  const Livre({
    required this.id,
    required this.titre,
    required this.auteur,
    this.annee,
    this.resume,
    required this.disponible,
  });

  final int id;
  final String titre;
  final String auteur;
  final int? annee;
  final String? resume;
  final bool disponible;

  /// `annee` et `resume` peuvent être `null` ou absents du JSON.
  factory Livre.fromJson(Map<String, dynamic> json) => Livre(
        id: json['id'] as int,
        titre: json['titre'] as String,
        auteur: json['auteur'] as String,
        annee: json['annee'] as int?,
        resume: json['resume'] as String?,
        disponible: json['disponible'] as bool? ?? false,
      );

  /// Copie de ce livre, marquée comme empruntée.
  Livre emprunte() => Livre(
        id: id,
        titre: titre,
        auteur: auteur,
        annee: annee,
        resume: resume,
        disponible: false,
      );
}
