import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/carrito_item.dart';
import 'api_config.dart';

class Comprobante {
  final int id;
  final String estado; // pendiente | aprobado | rechazado
  final String? imagen;

  Comprobante({required this.id, required this.estado, this.imagen});

  factory Comprobante.fromJson(Map<String, dynamic> j) => Comprobante(
        id: int.parse('${j['id_comprobante']}'),
        estado: (j['estado'] ?? 'pendiente').toString(),
        imagen: j['imagen']?.toString(),
      );
}

class ComprobanteService {
  static Map<String, String> _json(String token) =>
      {...ApiConfig.headers, 'Authorization': 'Bearer $token'};

  static Map<String, dynamic> _decode(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      return d is Map<String, dynamic> ? d : {};
    } catch (_) {
      return {};
    }
  }

  static String _error(http.Response r, String porDefecto) =>
      (_decode(r)['error'] ?? porDefecto).toString();

  /// El cliente sube la imagen del comprobante junto con los datos del pedido
  /// (nombre, dirección, teléfono y productos) para que el administrador los vea.
  static Future<Comprobante> subir({
    required String token,
    required Uint8List bytes,
    required String nombreArchivo,
    required String nombre,
    required String direccion,
    required String telefono,
    required List<CarritoItem> items,
    int? monto,
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse(ApiConfig.comprobantes));
    req.headers['Accept'] = 'application/json';
    req.headers['Authorization'] = 'Bearer $token';
    if (monto != null) req.fields['monto'] = '$monto';
    req.fields['nombre'] = nombre;
    req.fields['direccion'] = direccion;
    req.fields['telefono'] = telefono;
    req.fields['items'] = jsonEncode([
      for (final i in items)
        {'id_producto': int.tryParse(i.id), 'cantidad': i.cantidad},
    ]);

    final ext = nombreArchivo.toLowerCase().split('.').last;
    final subtipo = ext == 'png' ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');
    req.files.add(http.MultipartFile.fromBytes(
      'comprobante',
      bytes,
      filename: nombreArchivo,
      contentType: MediaType('image', subtipo),
    ));

    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final r = await http.Response.fromStream(streamed);
    if (r.statusCode != 201) {
      throw Exception(_error(r, 'No se pudo subir el comprobante'));
    }
    return Comprobante.fromJson(_decode(r)['comprobante']);
  }

  /// Consulta el estado actual de un comprobante
  static Future<Comprobante> consultar(String token, int id) async {
    final r = await http
        .get(Uri.parse('${ApiConfig.comprobantes}/$id'), headers: _json(token))
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) throw Exception(_error(r, 'No se pudo consultar'));
    return Comprobante.fromJson(_decode(r)['comprobante']);
  }

  /// Último comprobante del cliente que aún se puede usar (o null)
  static Future<Comprobante?> vigente(String token) async {
    final r = await http
        .get(Uri.parse('${ApiConfig.comprobantes}/mio/vigente'), headers: _json(token))
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) return null;
    final c = _decode(r)['comprobante'];
    return c is Map<String, dynamic> ? Comprobante.fromJson(c) : null;
  }

  /// Administrador: aprueba o rechaza
  static Future<void> validar(
    String token,
    dynamic id, {
    required bool aprobar,
    String? motivo,
  }) async {
    final r = await http
        .put(
          Uri.parse('${ApiConfig.comprobantes}/${int.parse('$id')}/validar'),
          headers: _json(token),
          body: jsonEncode({
            'estado': aprobar ? 'aprobado' : 'rechazado',
            if (motivo != null && motivo.isNotEmpty) 'motivo': motivo,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) throw Exception(_error(r, 'No se pudo validar el comprobante'));
  }
}