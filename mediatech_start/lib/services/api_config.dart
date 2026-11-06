import 'package:flutter/foundation.dart';

/// Adresse de base de l'API selon la plateforme d'exécution.
///
/// - Chrome (web) et simulateur iOS : `http://localhost:8000`
/// - Émulateur Android : `http://10.0.2.2:8000`
/// - iPhone ou téléphone réel : passer l'adresse du poste avec
///   `flutter run --dart-define=API_URL=http://192.168.1.20:8000`
class ApiConfig {
  const ApiConfig._();

  static String get baseUrl {
    const surcharge = String.fromEnvironment('API_URL');
    if (surcharge.isNotEmpty) return surcharge;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }
}
