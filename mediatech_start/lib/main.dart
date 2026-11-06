import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'screens/catalogue_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MediaTechApp());
}

class MediaTechApp extends StatelessWidget {
  const MediaTechApp({super.key, this.api});

  /// Service injectable pour les tests ; par défaut, le vrai service HTTP.
  final ApiService? api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediaTech',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // Sur Chrome et sur ordinateur, le glisser à la souris doit pouvoir
      // faire défiler les listes et déclencher le RefreshIndicator.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      home: CatalogueScreen(api: api),
    );
  }
}
