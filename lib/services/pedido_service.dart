import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/carrito_item.dart';
import 'api_config.dart';

/// Envía el pedido al backend: crea el pedido con sus detalles
/// (POST /api/pedidos), que también genera las notificaciones, y luego
/// registra el pago (POST /api/pagos).
/// El id del usuario lo saca el backend del token.
class PedidoService {
  static Map<String, dynamic> _json(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      return d is Map<String, dynamic> ? d : {};
    } catch (_) {
      return {};
    }
  }

  static Future<void> realizar({
    required String token,
    required String nombre,
    required String direccion,
    required String telefono,
    required String metodoPago,
    required List<CarritoItem> items,
    required int total,
     int? idComprobante, // solo para Nequi
  }) async {
    final cabeceras = {...ApiConfig.headers, 'Authorization': 'Bearer $token'};

    // 1) Crear el pedido con sus detalles
    final detalles = <Map<String, dynamic>>[];
    for (final i in items) {
      final idProducto = int.tryParse(i.id);
      if (idProducto == null) {
        throw Exception('Producto inválido en el pedido: ${i.nombre}');
      }
      detalles.add({
        'id_producto': idProducto,
        'nombre': i.nombre, // para el texto de la notificación
        'cantidad': i.cantidad,
        'precio_unitario': i.precio,
        'subtotal': i.subtotal,
      });
    }

    final r = await http
        .post(
          Uri.parse(ApiConfig.pedidos),
          headers: cabeceras,
          body: jsonEncode({
            'nombre': nombre,
            'direccion': direccion,
            'telefono': telefono,
            'metodo_pago': metodoPago, // Nequi | Efectivo (para la notificación)
            if (idComprobante != null) 'id_comprobante': idComprobante,
            'detalles': detalles,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final datos = _json(r);
    if (r.statusCode != 201) {
      throw Exception(
          datos['error']?.toString() ?? 'No se pudo crear el pedido');
    }
    final idPedido = datos['pedido']['id_pedido'];

    // 2) Registrar el pago
    final p = await http
        .post(
          Uri.parse(ApiConfig.pagos),
          headers: cabeceras,
          body: jsonEncode({
            'id_pedido': idPedido,
            'metodo_pago': metodoPago.toLowerCase(), // nequi | efectivo
            'monto': total,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (p.statusCode != 201) {
      throw Exception('El pedido se creó, pero no se pudo registrar el pago');
    }
  }
}