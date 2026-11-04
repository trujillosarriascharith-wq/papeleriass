//codigo funcional correcto hoy 11:28
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'api_config.dart';

// class ChatPapeleriaService {
//   static String get _chatUrl => ApiConfig.chat;

//   static Future<String> enviarMensaje(String mensaje, {String? sesionId}) async {
//     try {
//       final response = await http.post(
//         Uri.parse(_chatUrl),
//         headers: ApiConfig.headers,
//         body: jsonEncode({
//           'mensaje': mensaje,
//           'sesionId': sesionId ?? 'papeleria_cliente_${DateTime.now().millisecondsSinceEpoch}',
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(utf8.decode(response.bodyBytes));
//         return data['respuesta'] ?? data['mensaje'] ?? 'No se recibio respuesta.';
//       } else {
//         print('Error backend: ${response.statusCode} - ${response.body}');
//         return 'En este momento no pudimos procesar tu solicitud.';
//       }
//     } catch (e) {
//       print('Error de conexion: $e');
//       return 'Error de conexion con la papeleria. Revisa que tu servidor este corriendo en puerto 3000.';
//     }
//   }

 
//     }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_mensaje.dart';
import '../models/producto_model.dart';
import 'api_config.dart';
import 'sesion.dart';

class ChatPapeleriaService {
  static String get _url => '${ApiConfig.baseUrl}/api/chat';

  // Se conserva la sesión mientras la app esté abierta
  static String? _sesionId;

  static const String _errorConexion =
      'Error de conexión con la papelería. Revisa que tu servidor esté corriendo en puerto 3000';

  static Future<RespuestaChat> enviarMensaje(String mensaje) async {
    try {
      final r = await http
          .post(
            Uri.parse(_url),
            headers: {
              'Content-Type': 'application/json',
              // Si hay sesión se manda el token; el servidor decide si es admin
              if (Sesion.activa) 'Authorization': 'Bearer ${Sesion.token}',
            },
            body: jsonEncode({
              'mensaje': mensaje,
              if (_sesionId != null) 'sesionId': _sesionId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (r.statusCode != 200) {
        return const RespuestaChat(texto: _errorConexion);
      }

      final data = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      _sesionId = data['sesionId']?.toString() ?? _sesionId;

      final lista = (data['productos'] as List?) ?? [];
      final productos = lista
          .map((e) => ProductoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return RespuestaChat(
        texto: (data['respuesta'] ?? '').toString(),
        productos: productos,
        esStock: data['esStock'] == true,
      );
    } catch (_) {
      return const RespuestaChat(texto: _errorConexion);
    }
  }
}