import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/categoria_app.dart';
import 'api_config.dart';
import 'sesion.dart';

/// Categorías de la tienda, leídas de la tabla "categorias".
/// [categorias] es la lista compartida: los menús y el selector del formulario
/// la escuchan, así que cuando se crea una categoría aparece en todos.
class CategoriaService {
  static final ValueNotifier<List<CategoriaApp>> categorias =
      ValueNotifier<List<CategoriaApp>>([]);
  static final ValueNotifier<bool> cargando = ValueNotifier<bool>(false);

  static String get _url => '${ApiConfig.baseUrl}/api/categorias';

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

  /// Trae las categorías del servidor y actualiza la lista compartida.
  /// Si falla la conexión, conserva la lista que ya había.
  static Future<void> cargar() async {
    cargando.value = true;
    try {
      final r = await http
          .get(Uri.parse(_url), headers: ApiConfig.headers)
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) throw Exception(_mensajeError(r));

      final datos = jsonDecode(r.body);
      final lista = datos is List ? datos : datos['categorias'] as List;
      final nuevas = lista
          .map((e) => CategoriaApp.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      categorias.value = nuevas;
    } catch (_) {
      // Se conserva la lista anterior
    } finally {
      cargando.value = false;
    }
  }

  /// Crea una categoría con su foto (solo administrador) y refresca la lista.
  static Future<void> crear({
    required String nombre,
    required String descripcion,
    required Uint8List imagen,
    required String nombreImagen,
  }) async {
    final token = await _token();
    final peticion = http.MultipartRequest('POST', Uri.parse(_url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['nombre'] = nombre
      ..fields['descripcion'] = descripcion
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

    await cargar(); // la nueva categoría aparece en todas partes
  }
}