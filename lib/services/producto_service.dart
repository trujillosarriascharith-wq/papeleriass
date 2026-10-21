// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/producto_model.dart';
// import 'api_config.dart';

// class ProductoService {
//   // 1. Obtener la lista de productos para renderizar en el menú
//   Future<List<ProductoModel>> obtenerProductos() async {
//     final url = Uri.parse('${ApiConfig.baseUrl}/helados');

//     try {
//       final response = await http.get(url, headers: ApiConfig.headers);
//       final contentType = response.headers['content-type'] ?? '';

//       if (response.statusCode == 200) {
//         final List<dynamic> datos = jsonDecode(response.body);
//         return datos.map((item) => ProductoModel.fromJson(item)).toList();
//       } else {
//         if (contentType.contains('application/json')) {
//           final errorData = jsonDecode(response.body);
//           throw Exception(errorData['message'] ?? errorData['error'] ?? 'Error al cargar productos');
//         } else {
//           throw Exception('Error del servidor (Código ${response.statusCode})');
//         }
//       }
//     } catch (e) {
//       throw Exception(e.toString().replaceAll('Exception: ', ''));
//     }
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/producto_model.dart';
import 'api_config.dart';
import 'sesion.dart';

/// Conexión con el backend de productos (/api/productos).
class ProductoService {
  // Token de la sesión (en memoria, o el que se guardó al iniciar sesión)
  static Future<String> _token() async {
    if (Sesion.activa) return Sesion.token!;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  static String _mensajeError(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      final detalle = d['detalle'] != null ? ': ${d['detalle']}' : '';
      return '${d['error'] ?? d['message'] ?? 'Error del servidor'}$detalle';
    } catch (_) {
      return 'El servidor no respondió con JSON válido (código ${r.statusCode})';
    }
  }

  static MediaType _tipoImagen(String nombre) {
    final ext = nombre.contains('.') ? nombre.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'avif' => MediaType('image', 'avif'),
      _ => MediaType('image', 'jpeg'),
    };
  }

  /// Lista los productos. Con [idCategoria] trae solo los de esa categoría.
  static Future<List<ProductoModel>> listar({int? idCategoria}) async {
    final uri = Uri.parse(ApiConfig.productos).replace(
      queryParameters: idCategoria == null ? null : {'id_categoria': '$idCategoria'},
    );
    try {
      final r = await http
          .get(uri, headers: ApiConfig.headers)
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) throw Exception(_mensajeError(r));

      final datos = jsonDecode(r.body);
      final lista = datos is List ? datos : datos['productos'] as List;
      return lista
          .map((e) => ProductoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('No se pudo conectar con el servidor');
    } on http.ClientException {
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  /// Crea un producto con su imagen. Solo funciona con sesión de administrador.
  static Future<void> crear({
    required ProductoModel producto,
    required Uint8List imagen,
    required String nombreImagen,
  }) async {
    final token = await _token();
    final peticion = http.MultipartRequest('POST', Uri.parse(ApiConfig.productos))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll({
        'id_categoria': '${producto.idCategoria}',
        'nombre': producto.nombre,
        'descripcion': producto.descripcion.join(', '),
        'precio': '${producto.precio}',
        'cantidad_stock': '${producto.cantidadStock}',
        'estado': producto.estado,
      })
      ..files.add(http.MultipartFile.fromBytes(
        'imagen',
        imagen,
        filename: nombreImagen,
        contentType: _tipoImagen(nombreImagen),
      ));

    try {
      final enviada = await peticion.send().timeout(const Duration(seconds: 60));
      final r = await http.Response.fromStream(enviada);
      if (r.statusCode != 201) throw Exception(_mensajeError(r));
    } on TimeoutException {
      throw Exception('El servidor tardó demasiado en responder');
    } on http.ClientException {
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  // Compatibilidad con pantallas viejas que usaban ProductoService().obtenerProductos()
  Future<List<ProductoModel>> obtenerProductos() => listar();
}