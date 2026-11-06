import 'package:flutter/material.dart';

import '../models/livre.dart';
import '../services/api_service.dart';
import '../widgets/livre_tile.dart';
import 'detail_screen.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key, this.api});

  final ApiService? api;

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  late final ApiService _api = widget.api ?? ApiService();

  List<Livre> _livres = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger(initial: true);
  }

  Future<void> _charger({bool initial = false}) async {
    if (!initial) {
      setState(() {
        _chargement = _livres.isEmpty;
        _erreur = null;
      });
    }
    try {
      final livres = await _api.fetchLivres();
      if (!mounted) return;
      setState(() {
        _livres = livres;
        _chargement = false;
      });
    } on ApiException catch (e) {
      _signalerErreur(e.message);
    } catch (_) {
      _signalerErreur('Une erreur inattendue est survenue.');
    }
  }

  void _signalerErreur(String message) {
    if (!mounted) return;
    setState(() {
      _erreur = message;
      _chargement = false;
    });
    // Si une liste est déjà affichée, on la garde et on prévient par un message.
    if (_livres.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _ouvrirDetail(Livre livre) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(
          livre: livre,
          api: _api,
          onReservee: () => _marquerEmprunte(livre.id),
        ),
      ),
    );
  }

  void _marquerEmprunte(int id) {
    if (!mounted) return;
    setState(() {
      _livres = [
        for (final livre in _livres)
          if (livre.id == id) livre.emprunte() else livre,
      ];
    });
  }

  Widget _corps() {
    if (_chargement && _livres.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erreur != null && _livres.isEmpty) {
      return _MessagePlein(
        icone: Icons.wifi_off,
        message: _erreur!,
        action: FilledButton(
          onPressed: _charger,
          child: const Text('Réessayer'),
        ),
      );
    }
    if (_livres.isEmpty) {
      return const _MessagePlein(
        icone: Icons.menu_book_outlined,
        message: 'Aucun livre dans le catalogue.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _livres.length,
      itemBuilder: (context, index) {
        final livre = _livres[index];
        return LivreTile(livre: livre, onTap: () => _ouvrirDetail(livre));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaTech'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _charger,
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _charger, child: _corps()),
    );
  }
}

/// Message centré (erreur, liste vide). C'est un `ListView` pour que le
/// tirage vers le bas (RefreshIndicator) fonctionne aussi dans ces états.
class _MessagePlein extends StatelessWidget {
  const _MessagePlein(
      {required this.icone, required this.message, this.action});

  final IconData icone;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(icone, size: 56, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        if (action != null) ...[
          const SizedBox(height: 16),
          Center(child: action!),
        ],
      ],
    );
  }
}
