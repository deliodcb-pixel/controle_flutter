import 'package:flutter/material.dart';

class DisponibiliteChip extends StatelessWidget {
  const DisponibiliteChip({super.key, required this.disponible});

  final bool disponible;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Chip(
      label: Text(disponible ? 'Disponible' : 'Emprunté'),
      visualDensity: VisualDensity.compact,
      backgroundColor:
          disponible ? couleurs.primaryContainer : couleurs.errorContainer,
      side: BorderSide.none,
    );
  }
}
