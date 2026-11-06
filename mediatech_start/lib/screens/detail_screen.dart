import 'package:flutter/material.dart';

import '../models/livre.dart';
import '../services/api_service.dart';
import '../widgets/disponibilite_chip.dart';
import 'reservation_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.livre,
    required this.api,
    required this.onReservee,
  });

  final Livre livre;
  final ApiService api;

  /// Prévient l'écran appelant qu'une réservation de ce livre est confirmée.
  final VoidCallback onReservee;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Livre _livre = widget.livre;

  void _marquerEmprunte() {
    widget.onReservee();
    // La fiche a pu être quittée pendant l'envoi de la réservation.
    if (!mounted) return;
    setState(() => _livre = _livre.emprunte());
  }

  @override
  Widget build(BuildContext context) {
    final textes = Theme.of(context).textTheme;
    final livre = _livre;
    return Scaffold(
      appBar: AppBar(title: Text(livre.titre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(livre.titre, style: textes.headlineSmall),
          const SizedBox(height: 4),
          Text(livre.auteur, style: textes.titleMedium),
          const SizedBox(height: 4),
          Text('Année : ${livre.annee ?? 'inconnue'}'),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: DisponibiliteChip(disponible: livre.disponible),
          ),
          const SizedBox(height: 16),
          Text(
            livre.resume == null
                ? 'Aucun résumé disponible.'
                : 'Résumé : ${livre.resume}',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            // `null` désactive le bouton lorsque le livre est emprunté.
            onPressed: livre.disponible
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReservationScreen(
                          livre: livre,
                          api: widget.api,
                          onReservee: _marquerEmprunte,
                        ),
                      ),
                    )
                : null,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Réserver'),
          ),
        ],
      ),
    );
  }
}
