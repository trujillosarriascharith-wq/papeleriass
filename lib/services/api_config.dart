import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Web (Chrome) usa localhost; el emulador Android usa 10.0.2.2
  static String get baseUrl {
    // 1. Evaluar Web primero para evitar que Platform.isX genere un error en JS
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // 2. Evaluaciones para dispositivos móviles / desktop
    if (Platform.isAndroid) {
      // Emulador de Android
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      // Simulador de iOS
      return 'http://localhost:3000';
    }

    // Fallback para macOS, Windows, Linux, etc.
    return 'http://localhost:3000';
  }

  static String get chat => '$baseUrl/api/chat';
  static String get productos => '$baseUrl/api/productos';
  static String get auth => '$baseUrl/auth';
  static String get notificaciones => '$baseUrl/api/notificaciones';
  static String get perfil => '$baseUrl/api/perfil';
  //nueva ruta para el carrito
  static String get pedidos => '$baseUrl/api/pedidos';
  static String get pagos => '$baseUrl/api/pagos';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}