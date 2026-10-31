// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'api_config.dart'; // ajusta la ruta si está en otra carpeta

// class ServicioRecuperacion {
//   /// Pide al backend que genere y envíe el código al correo
//   static Future<void> enviarCodigo(String correo) async {
//     final r = await http
//         .post(
//           Uri.parse('${ApiConfig.auth}/forgot-password'),
//           headers: ApiConfig.headers,
//           body: jsonEncode({'email': correo}),
//         )
//         .timeout(const Duration(seconds: 20));
//     if (r.statusCode != 200) throw Exception(_mensaje(r));
//   }

//   /// Valida el código y cambia la contraseña
//   static Future<void> cambiarContrasena({
//     required String correo,
//     required String codigo,
//     required String password,
//   }) async {
//     final r = await http
//         .post(
//           Uri.parse('${ApiConfig.auth}/verify-code'),
//           headers: ApiConfig.headers,
//           body: jsonEncode({
//             'email': correo,
//             'codigo': codigo,
//             'nuevapassword': password,
//           }),
//         )
//         .timeout(const Duration(seconds: 20));
//     if (r.statusCode != 200) throw Exception(_mensaje(r));
//   }

//   static String _mensaje(http.Response r) {
//     try {
//       final body = jsonDecode(r.body);
//       return body['error'] ?? body['message'] ?? 'Ocurrió un error';
//     } catch (_) {
//       return 'Ocurrió un error (${r.statusCode})';
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ServicioRecuperacion {
  /// Pide al backend que genere y envíe el código al correo
  static Future<void> enviarCodigo(String correo) async {
    try {
      final r = await http
          .post(
            Uri.parse('${ApiConfig.auth}/forgot-password'),
            headers: ApiConfig.headers,
            body: jsonEncode({'email': correo}),
          )
          .timeout(const Duration(seconds: 60)); // <- ANTES 20, AHORA 60
      if (r.statusCode != 200) throw Exception(_mensaje(r));
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('El servidor está despertando, intenta de nuevo en 10 segundos');
      }
      rethrow;
    }
  }

  /// Valida el código y cambia la contraseña
  static Future<void> cambiarContrasena({
    required String correo,
    required String codigo,
    required String password,
  }) async {
    try {
      final r = await http
          .post(
            Uri.parse('${ApiConfig.auth}/verify-code'),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'email': correo,
              'codigo': codigo,
              'nuevapassword': password,
            }),
          )
          .timeout(const Duration(seconds: 60)); // <- ANTES 20, AHORA 60
      if (r.statusCode != 200) throw Exception(_mensaje(r));
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('El servidor está despertando, intenta de nuevo en 10 segundos');
      }
      rethrow;
    }
  }

  static String _mensaje(http.Response r) {
    try {
      final body = jsonDecode(r.body);
      return body['error'] ?? body['message'] ?? 'Ocurrió un error';
    } catch (_) {
      return 'Ocurrió un error (${r.statusCode})';
    }
  }
}