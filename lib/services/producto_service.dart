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

  /// Actualiza un producto existente (con opción de cambiar imagen o mantener la anterior).
  static Future<void> actualizar({
    required int id,
    required ProductoModel producto,
    Uint8List? imagenBytes,
    String? nombreImagen,
  }) async {
    final token = await _token();
    final peticion = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.productos}/$id'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll({
        'id_categoria': '${producto.idCategoria}',
        'nombre': producto.nombre,
        'descripcion': producto.descripcion.join(', '),
        'precio': '${producto.precio}',
        'cantidad_stock': '${producto.cantidadStock}',
        'estado': producto.estado,
      });

    // Si el administrador seleccionó una nueva imagen, se adjunta
    if (imagenBytes != null && nombreImagen != null && nombreImagen.isNotEmpty) {
      peticion.files.add(http.MultipartFile.fromBytes(
        'imagen',
        imagenBytes,
        filename: nombreImagen,
        contentType: _tipoImagen(nombreImagen),
      ));
    }

    try {
      final enviada = await peticion.send().timeout(const Duration(seconds: 60));
      final r = await http.Response.fromStream(enviada);
      if (r.statusCode != 200) throw Exception(_mensajeError(r));
    } on TimeoutException {
      throw Exception('El servidor tardó demasiado en responder');
    } on http.ClientException {
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  /// Elimina un producto por su ID mediante la ruta DELETE.
  static Future<void> eliminar(int id) async {
    final token = await _token();
    try {
      final r = await http.delete(
        Uri.parse('${ApiConfig.productos}/$id'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (r.statusCode != 200) throw Exception(_mensajeError(r));
    } on TimeoutException {
      throw Exception('No se pudo conectar con el servidor');
    } on http.ClientException {
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  // Compatibilidad con pantallas viejas que usaban ProductoService().obtenerProductos()
  Future<List<ProductoModel>> obtenerProductos() => listar();
}