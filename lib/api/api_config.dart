import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String configuredBaseUrl = String.fromEnvironment(
    'GYM_API_BASE_URL',
  );

  static String get baseUrl {
    final configured = configuredBaseUrl.trim();
    if (configured.isNotEmpty) return normalizeBaseUrl(configured);

    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    return normalizeBaseUrl('http://$host:3001/api/v1');
  }

  static String normalizeBaseUrl(String value) {
    final uri = Uri.tryParse(value.trim());

    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('Invalid Gym API URL.');
    }

    var path = uri.path.replaceFirst(RegExp(r'/+$'), '');
    path = path.replaceFirst(RegExp(r'/physio$', caseSensitive: false), '');

    if (path.isEmpty) {
      path = '/api/v1';
    } else if (!path.endsWith('/api/v1')) {
      path = '$path/api/v1';
    }

    return uri.replace(path: path).toString();
  }

  static const Duration timeout = Duration(seconds: 20);
}
