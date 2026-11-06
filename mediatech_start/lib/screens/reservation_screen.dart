import 'package:flutter/material.dart';

import '../models/livre.dart';
import '../services/api_service.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({
    super.key,
    required this.livre,
    required this.api,
    required this.onReservee,
  });

  final Livre livre;
  final ApiService api;

  /// Appelé quand le serveur a confirmé la réservation, même si le formulaire
  /// a été quitté pendant l'envoi.
  final VoidCallback onReservee;

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  static final _formatEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _envoi = false;
  String? _erreur;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _validerNom(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Le nom est obligatoire.';
    }
    return null;
  }

  String? _validerEmail(String? valeur) {
    if (valeur == null || !_formatEmail.hasMatch(valeur.trim())) {
      return 'Saisissez une adresse e-mail valide.';
    }
    return null;
  }

  Future<void> _envoyer() async {
    if (!_formKey.currentState!.validate()) return;

    // On récupère ces objets avant l'await : le contexte ne doit pas
    // être utilisé après une pause asynchrone.
    final messager = ScaffoldMessenger.of(context);
    final navigateur = Navigator.of(context);
    final route = ModalRoute.of(context);

    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      await widget.api.reserver(
        livreId: widget.livre.id,
        nom: _nomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      widget.onReservee();
      messager.showSnackBar(
        SnackBar(
          content: Text('Réservation confirmée pour « ${widget.livre.titre} ».'),
        ),
      );
      // Le formulaire a pu être quitté pendant l'envoi : ne pas fermer un
      // autre écran à sa place. `mounted` ne suffit pas, car il reste vrai
      // pendant l'animation de retour.
      if (route?.isCurrent ?? false) {
        navigateur.popUntil((r) => r.isFirst);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        _envoi = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erreur = 'Une erreur inattendue est survenue.';
        _envoi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réserver')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.livre.titre,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: _validerNom,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validerEmail,
            ),
            if (_erreur != null) ...[
              const SizedBox(height: 16),
              Text(
                _erreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _envoi ? null : _envoyer,
              child: _envoi
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmer la réservation'),
            ),
          ],
        ),
      ),
    );
  }
}
