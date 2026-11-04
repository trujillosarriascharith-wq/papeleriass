// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api_config.dart';
// import 'sesion.dart';

// class AuthResultado {
//   final bool exito;
//   final String mensaje;
//   final Map<String, dynamic>? usuario;
//   final bool noVerificado;
//   AuthResultado(this.exito, this.mensaje, {this.usuario, this.noVerificado = false});
// }

// class AuthService {
//   static Future<AuthResultado> login({
//     required String nombre,
//     required String correo,
//     required String password,
//   }) async {
//     try {
//       final res = await http
//           .post(
//             Uri.parse('${ApiConfig.auth}/login'),
//             headers: ApiConfig.headers,
//             body: jsonEncode({
//               'nombre': nombre,
//               'email': correo,
//               'password': password,
//             }),
//           )
//           .timeout(const Duration(seconds: 15));

//       final data = jsonDecode(res.body) as Map<String, dynamic>;

//       if (res.statusCode == 200) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', data['token']);
//         await prefs.setString('usuario', jsonEncode(data['usuario']));
//         Sesion.token = data['token'];
        
//         return AuthResultado(true, data['message'] ?? 'Listo',
//             usuario: data['usuario']);
//       }

//       return AuthResultado(false, data['error'] ?? 'Error al iniciar sesión',
//           noVerificado: res.statusCode == 403);
//     } catch (e) {
//       return AuthResultado(false, 'No se pudo conectar con el servidor');
//     }
//   }

//   /// Registro con foto opcional (multipart)
//   static Future<AuthResultado> registrar({
//     required String nombre,
//     required String correo,
//     required String telefono,
//     required String direccion,
//     required String password,
//     Uint8List? foto,
//   }) async {
//     try {
//       final req = http.MultipartRequest(
//         'POST',
//         Uri.parse('${ApiConfig.auth}/register'),
//       )..fields.addAll({
//           'nombre': nombre,
//           'email': correo,
//           'telefono': telefono,
//           'direccion': direccion,
//           'password': password,
//         });

//       if (foto != null) {
//         req.files.add(
//           http.MultipartFile.fromBytes('foto', foto, filename: 'foto.jpg'),
//         );
//       }

//       final streamed = await req.send().timeout(const Duration(seconds: 30));
//       final res = await http.Response.fromStream(streamed);
//       final data = jsonDecode(res.body) as Map<String, dynamic>;

//       if (res.statusCode == 201) {
//         return AuthResultado(true, data['message'] ?? 'Cuenta creada',
//             usuario: data['usuarios'] as Map<String, dynamic>?);
//       }
//       return AuthResultado(false, data['error'] ?? 'Error al registrarse');
//     } catch (e) {
//       return AuthResultado(false, 'No se pudo conectar con el servidor');
//     }
//   }

//   /// Verifica la cuenta con el código de 6 dígitos del correo
//   static Future<AuthResultado> verificarCuenta({
//     required String correo,
//     required String codigo,
//   }) async {
//     try {
//       final res = await http
//           .post(
//             Uri.parse('${ApiConfig.auth}/verify-account'),
//             headers: ApiConfig.headers,
//             body: jsonEncode({'email': correo, 'codigoVerificacion': codigo}),
//           )
//           .timeout(const Duration(seconds: 15));

//       final data = jsonDecode(res.body) as Map<String, dynamic>;
//       if (res.statusCode == 200) {
//         return AuthResultado(true, data['message'] ?? 'Cuenta verificada');
//       }
//       return AuthResultado(false, data['error'] ?? 'Código incorrecto');
//     } catch (e) {
//       return AuthResultado(false, 'No se pudo conectar con el servidor');
//     }
//   }

//   /// Usuario guardado al iniciar sesión (para el perfil)
//   static Future<Map<String, dynamic>?> usuarioGuardado() async {
//     final prefs = await SharedPreferences.getInstance();
//     final texto = prefs.getString('usuario');
//     if (texto == null) return null;
//     return jsonDecode(texto) as Map<String, dynamic>;
//   }

//   static Future<void> cerrarSesion() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('usuario');
//     Sesion.cerrar();
//   }
// }
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'sesion.dart';

class AuthResultado {
  final bool exito;
  final String mensaje;
  final Map<String, dynamic>? usuario;
  final bool noVerificado;
  final bool requiereVerificacion; // true si hay que confirmar un correo nuevo
  AuthResultado(
    this.exito,
    this.mensaje, {
    this.usuario,
    this.noVerificado = false,
    this.requiereVerificacion = false,
  });
}

class AuthService {
  static Future<AuthResultado> login({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.auth}/login'),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'nombre': nombre,
              'email': correo,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('usuario', jsonEncode(data['usuario']));
        Sesion.token = data['token'];
        
        return AuthResultado(true, data['message'] ?? 'Listo',
            usuario: data['usuario']);
      }

      return AuthResultado(false, data['error'] ?? 'Error al iniciar sesión',
          noVerificado: res.statusCode == 403);
    } catch (e) {
      return AuthResultado(false, 'No se pudo conectar con el servidor');
    }
  }

  /// Registro con foto opcional (multipart)
  static Future<AuthResultado> registrar({
    required String nombre,
    required String correo,
    required String telefono,
    required String direccion,
    required String password,
    Uint8List? foto,
  }) async {
    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.auth}/register'),
      )..fields.addAll({
          'nombre': nombre,
          'email': correo,
          'telefono': telefono,
          'direccion': direccion,
          'password': password,
        });

      if (foto != null) {
        req.files.add(
          http.MultipartFile.fromBytes('foto', foto, filename: 'foto.jpg'),
        );
      }

      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 201) {
        return AuthResultado(true, data['message'] ?? 'Cuenta creada',
            usuario: data['usuarios'] as Map<String, dynamic>?);
      }
      return AuthResultado(false, data['error'] ?? 'Error al registrarse');
    } catch (e) {
      return AuthResultado(false, 'No se pudo conectar con el servidor');
    }
  }

  /// Verifica la cuenta con el código de 6 dígitos del correo
  static Future<AuthResultado> verificarCuenta({
    required String correo,
    required String codigo,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.auth}/verify-account'),
            headers: ApiConfig.headers,
            body: jsonEncode({'email': correo, 'codigoVerificacion': codigo}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return AuthResultado(true, data['message'] ?? 'Cuenta verificada');
      }
      return AuthResultado(false, data['error'] ?? 'Código incorrecto');
    } catch (e) {
      return AuthResultado(false, 'No se pudo conectar con el servidor');
    }
  }

  /// Usuario guardado al iniciar sesión (para el perfil)
  static Future<Map<String, dynamic>?> usuarioGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString('usuario');
    if (texto == null) return null;
    return jsonDecode(texto) as Map<String, dynamic>;
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuario');
    Sesion.cerrar();
  }

  // ====================== PERFIL ======================

  /// Token de la sesión (memoria o, si hace falta, el guardado en el teléfono)
  static Future<String?> _token() async {
    if (Sesion.activa) return Sesion.token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Guarda el token nuevo que manda el servidor al actualizar el perfil
  static Future<void> _guardarToken(dynamic token) async {
    if (token is! String || token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    Sesion.token = token;
  }

  /// Mezcla los datos nuevos con el usuario guardado y lo vuelve a guardar
  static Future<Map<String, dynamic>> _guardarUsuario(
      Map<String, dynamic> nuevos) async {
    final prefs = await SharedPreferences.getInstance();
    final actual = await usuarioGuardado() ?? <String, dynamic>{};
    final fusion = <String, dynamic>{...actual, ...nuevos};
    await prefs.setString('usuario', jsonEncode(fusion));
    return fusion;
  }

  /// Petición con cuerpo JSON y token
  static Future<http.Response> _enviarJson(
    String metodo,
    String ruta,
    Map<String, dynamic> cuerpo,
    String token,
  ) async {
    final req = http.Request(metodo, Uri.parse('${ApiConfig.baseUrl}$ruta'))
      ..headers['Content-Type'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..body = jsonEncode(cuerpo);
    final streamed = await req.send().timeout(const Duration(seconds: 20));
    return http.Response.fromStream(streamed);
  }

  static Map<String, dynamic> _mapa(http.Response r) =>
      jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;

  /// Pide al servidor los datos más recientes del usuario y los guarda.
  /// Devuelve null si no hay sesión o no hay conexión.
  static Future<Map<String, dynamic>?> refrescarPerfil() async {
    try {
      final token = await _token();
      if (token == null) return null;

      final res = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/perfil'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return null;

      final u = _mapa(res)['usuario'];
      if (u is! Map) return null;
      return _guardarUsuario(Map<String, dynamic>.from(u));
    } catch (_) {
      return null;
    }
  }

  /// Guarda en la base de datos nombre, dirección y teléfono. Si el correo
  /// cambió, queda pendiente y [AuthResultado.requiereVerificacion] es true.
  static Future<AuthResultado> actualizarPerfil({
    required String nombre,
    required String correo,
    required String direccion,
    required String telefono,
  }) async {
    try {
      final token = await _token();
      if (token == null) {
        return AuthResultado(false, 'Inicia sesión para editar tu perfil');
      }

      final res = await _enviarJson(
        'PUT',
        '/api/perfil',
        {
          'nombre': nombre,
          'email': correo,
          'direccion': direccion,
          'telefono': telefono,
        },
        token,
      );
      final data = _mapa(res);

      if (res.statusCode == 200) {
        await _guardarToken(data['token']);
        final u = await _guardarUsuario(
          Map<String, dynamic>.from((data['usuario'] as Map?) ?? {}),
        );
        return AuthResultado(
          true,
          data['message'] ?? 'Perfil actualizado',
          usuario: u,
          requiereVerificacion: data['requiereVerificacion'] == true,
        );
      }
      return AuthResultado(
          false, data['error'] ?? 'No se pudo actualizar el perfil');
    } catch (_) {
      return AuthResultado(false, 'No se pudo conectar con el servidor');
    }
  }

  /// Confirma el correo nuevo con el código de 6 dígitos
  static Future<AuthResultado> verificarCorreoNuevo(String codigo) async {
    try {
      final token = await _token();
      if (token == null) {
        return AuthResultado(false, 'Inicia sesión para continuar');
      }

      final res = await _enviarJson(
        'POST',
        '/api/perfil/verificar-email',
        {'codigo': codigo},
        token,
      );
      final data = _mapa(res);

      if (res.statusCode == 200) {
        await _guardarToken(data['token']);
        final u = await _guardarUsuario(
          Map<String, dynamic>.from((data['usuario'] as Map?) ?? {}),
        );
        return AuthResultado(true, data['message'] ?? 'Correo actualizado',
            usuario: u);
      }
      return AuthResultado(false, data['error'] ?? 'Código incorrecto');
    } catch (_) {
      return AuthResultado(false, 'No se pudo conectar con el servidor');
    }
  }

  /// Pide un código nuevo para el correo pendiente
  static Future<AuthResultado> reenviarCodigoCorreo() async {
    try {
      final token = await _token();
      if (token == null) {
        return AuthResultado(false, 'Inicia sesión para continuar');
      }

      final res =
          await _enviarJson('POST', '/api/perfil/reenviar-codigo', {}, token);
      final data = _mapa(res);

      if (res.statusCode == 200) {
        return AuthResultado(true, data['message'] ?? 'Código enviado');
      }
      return AuthResultado(
          false, data['error'] ?? 'No se pudo enviar el código');
    } catch (_) {
      return AuthResultado(false, 'No se pudo conectar con el servidor');
    }
  }

  /// Sube la nueva foto de perfil y guarda su URL
  static Future<AuthResultado> subirFotoPerfil(Uint8List foto) async {
    try {
      final token = await _token();
      if (token == null) {
        return AuthResultado(false, 'Inicia sesión para cambiar tu foto');
      }

      final req = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/perfil/foto'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          http.MultipartFile.fromBytes('foto', foto, filename: 'foto.jpg'),
        );

      final streamed = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);
      final data = _mapa(res);

      if (res.statusCode == 200) {
        final url = (data['foto'] ?? '').toString();
        final u = await _guardarUsuario({'foto': url});
        return AuthResultado(true, data['message'] ?? 'Foto actualizada',
            usuario: u);
      }
      return AuthResultado(false, data['error'] ?? 'No se pudo subir la foto');
    } catch (_) {
      return AuthResultado(false, 'No se pudo conectar con el servidor');
    }
  }
}