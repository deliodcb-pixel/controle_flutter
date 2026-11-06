import 'package:flutter/material.dart';

import '../models/livre.dart';
import 'disponibilite_chip.dart';

class LivreTile extends StatelessWidget {
  const LivreTile({super.key, required this.livre, required this.onTap});

  final Livre livre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(livre.titre),
      subtitle: Text('${livre.auteur} (${livre.annee ?? 'année inconnue'})'),
      trailing: DisponibiliteChip(disponible: livre.disponible),
      onTap: onTap,
    );
  }
}
