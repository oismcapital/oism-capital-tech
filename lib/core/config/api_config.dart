import 'dart:io';

import 'package:flutter/foundation.dart';

/// Base URL da API Spring Boot.
///
/// - Android Emulator: `10.0.2.2` aponta para o localhost da máquina host.
/// - Windows/Desktop/Web: `127.0.0.1` ou `localhost`.
///
/// Ajuste a porta conforme seu `application.properties` (`server.port`).
class ApiConfig {
  ApiConfig._();

  static const int defaultPort = 8080;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$defaultPort';
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:$defaultPort';
    }
    return 'http://127.0.0.1:$defaultPort';
  }
}
